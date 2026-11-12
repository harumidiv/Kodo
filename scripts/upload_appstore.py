#!/usr/bin/env python3
"""Add localized metadata and screenshots without submitting a version for review.

Uses only the Python standard library and OpenSSL. Credentials are supplied via
arguments; private keys, JWTs, and signed asset URLs are never written to reports.
"""
import argparse
import base64
import hashlib
import json
import struct
import subprocess
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path


BASE = "https://api.appstoreconnect.apple.com"
ROOT = Path(__file__).resolve().parents[1]


def save(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n")


def relation(kind, identifier):
    return {"data": {"type": kind, "id": identifier}}


def payload(kind, attributes, relationships=None, identifier=None):
    data = {"type": kind, "attributes": attributes}
    if relationships:
        data["relationships"] = relationships
    if identifier:
        data["id"] = identifier
    return {"data": data}


class AppleAPI:
    def __init__(self, key, issuer):
        self.key = key
        self.issuer = issuer
        self.jwt = None
        self.expires = 0

    def token(self):
        if time.time() < self.expires - 60:
            return self.jwt
        def b64(value):
            return base64.urlsafe_b64encode(value).rstrip(b"=")
        now = int(time.time())
        kid = self.key.stem.removeprefix("AuthKey_")
        header = {"alg": "ES256", "kid": kid, "typ": "JWT"}
        claims = {"iss": self.issuer, "iat": now, "exp": now + 1100,
                  "aud": "appstoreconnect-v1"}
        message = b".".join(b64(json.dumps(v).encode()) for v in (header, claims))
        der = subprocess.run(["openssl", "dgst", "-sha256", "-sign", str(self.key)],
                             input=message, capture_output=True, check=True).stdout
        pos = 2 + (der[1] & 127) if der[1] & 128 else 2
        components = []
        for _ in range(2):
            assert der[pos] == 2
            size = der[pos + 1]
            pos += 2
            components.append(int.from_bytes(der[pos:pos + size], "big").to_bytes(32, "big"))
            pos += size
        self.jwt = (message + b"." + b64(b"".join(components))).decode()
        self.expires = now + 1100
        return self.jwt

    def request(self, path, method="GET", body=None):
        url = path if path.startswith(BASE + "/") else BASE + path
        if not url.startswith(BASE + "/"):
            raise ValueError("Unexpected API host")
        headers = {"Authorization": "Bearer " + self.token(), "Content-Type": "application/json"}
        data = None if body is None else json.dumps(body).encode()
        request = urllib.request.Request(url, data=data, method=method, headers=headers)
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                result = response.read()
                return json.loads(result) if result else None
        except urllib.error.HTTPError as error:
            raise RuntimeError(f"Apple API {method} {path.split('?')[0]}: "
                               f"{error.code} {error.read().decode()}") from None

    def all(self, path):
        result = []
        while path:
            response = self.request(path)
            result.extend(response["data"])
            path = response.get("links", {}).get("next")
        return result


def validate(metadata):
    for locale, fields in metadata["localizations"].items():
        assert locale not in metadata["preserveLocales"]
        for name, limit in [("name", 30), ("subtitle", 30), ("description", 4000),
                            ("promotionalText", 170), ("whatsNew", 4000)]:
            if not 0 < len(fields[name]) <= limit:
                raise ValueError(f"{locale}: {name} exceeds {limit}")
        if len(fields["keywords"].encode()) > 100:
            raise ValueError(f"{locale}: keywords exceed 100 bytes")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--key", type=Path, required=True)
    parser.add_argument("--issuer", required=True)
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--verify-only", action="store_true")
    args = parser.parse_args()
    metadata = json.loads((ROOT / "appstore/metadata.json").read_text())
    manifest = json.loads((ROOT / "screenshots/manifest.json").read_text())
    validate(metadata)
    api = AppleAPI(args.key, args.issuer)
    apps = api.all("/v1/apps?" + urllib.parse.urlencode({"filter[bundleId]": metadata["bundleId"]}))
    assert len(apps) == 1
    app_id = apps[0]["id"]
    versions = api.all(f"/v1/apps/{app_id}/appStoreVersions?filter[platform]=IOS")
    version = next(v for v in versions if v["attributes"]["versionString"] == metadata["version"])
    assert version["attributes"]["appStoreState"] == "PREPARE_FOR_SUBMISSION"
    vid = version["id"]
    infos = api.all(f"/v1/apps/{app_id}/appInfos")
    info = next(v for v in infos if v["attributes"]["appStoreState"] == "PREPARE_FOR_SUBMISSION")
    iid = info["id"]
    before_v = api.all(f"/v1/appStoreVersions/{vid}/appStoreVersionLocalizations")
    before_i = api.all(f"/v1/appInfos/{iid}/appInfoLocalizations")
    library = api.request(f"/v1/apps/{app_id}/assetLibrary")["data"]["id"]
    reference = api.request("/v1/appAssetLibraryRefData")["data"][0]["attributes"]
    placement_type = next(t for t in reference["placementTypes"] if t["placementTypeId"] == "APP_SCREENSHOT")
    feature = next(f for f in reference["features"] if f["featureId"] == "APP_STORE_VERSIONS")
    policy = next(p for p in feature["placementPolicies"] if p["placementType"] == "APP_SCREENSHOT")
    images = {}
    for entry in manifest["screenshots"]:
        path = ROOT / "screenshots" / entry["file"]
        data = path.read_bytes()
        assert hashlib.sha256(data).hexdigest() == entry["sha256"]
        assert data[25] == 2  # RGB, with no alpha channel
        width, height = struct.unpack(">II", data[16:24])
        specs = [s for s in reference["imageSpecs"]
                 if s["dimensions"]["minWidth"] == width and s["dimensions"]["maxWidth"] == width
                 and s["dimensions"]["minHeight"] == height and s["dimensions"]["maxHeight"] == height]
        matches = [(s, m) for s in specs for m in placement_type["specMappings"] if s["specId"] in m["specs"]]
        assert len(matches) == 1, (width, height, matches)
        spec, mapping = matches[0]
        group = mapping["placementGroupId"]
        assert any(group in g["groupIds"] and g["maxCount"] >= 3 for g in policy["groupLimits"])
        images[entry["file"]] = {"entry": entry, "spec": spec["specId"], "group": group}
    assert len(images) == 48
    print(f"Validated {len(metadata['localizations'])} locales and {len(images)} screenshots for {metadata['version']}", flush=True)
    print("Groups:", sorted({x["group"] for x in images.values()}), flush=True)
    if not args.apply and not args.verify_only:
        return
    checkpoint = ROOT / "appstore/upload-state.json"
    state = json.loads(checkpoint.read_text()) if checkpoint.exists() else {"versionId": vid, "metadata": {}, "images": {}, "placements": {}}
    assert state["versionId"] == vid
    if args.verify_only:
        verify(api, metadata, manifest, app_id, vid, iid, state)
        return
    baseline_path = ROOT / "appstore/protected-locales-before.json"
    if not baseline_path.exists():
        protected = {"version": {}, "info": {}, "placements": {}}
        for kind, rows in [("version", before_v), ("info", before_i)]:
            for row in rows:
                locale = row["attributes"]["locale"]
                if locale in metadata["preserveLocales"]:
                    protected[kind][locale] = row
                    if kind == "version":
                        protected["placements"][locale] = api.all(f"/v1/appStoreVersionLocalizations/{row['id']}/placements?sort=placementGroupPosition")
        save(baseline_path, protected)
    vmap = {r["attributes"]["locale"]: r for r in before_v}
    imap = {r["attributes"]["locale"]: r for r in before_i}
    for locale, fields in metadata["localizations"].items():
        ia = {k: fields[k] for k in ["name", "subtitle"]}
        ia["privacyPolicyUrl"] = metadata["sharedUrls"]["privacyPolicyUrl"]
        va = {k: fields[k] for k in ["description", "keywords", "promotionalText", "whatsNew"]}
        va.update({k: metadata["sharedUrls"][k] for k in ["supportUrl", "marketingUrl"]})
        for kind, attrs, rows, parent_type, parent_id, relationship in [
            ("appInfoLocalizations", ia, imap, "appInfos", iid, "appInfo"),
            ("appStoreVersionLocalizations", va, vmap, "appStoreVersions", vid, "appStoreVersion")]:
            # Creating one resource can cause Apple to add its counterpart.
            # Re-read before creating to avoid duplicate locale records.
            if locale not in rows:
                refreshed = api.all(f"/v1/{parent_type}/{parent_id}/{kind}")
                rows.update({r["attributes"]["locale"]: r for r in refreshed})
            if locale not in rows:
                body = payload(kind, dict(attrs, locale=locale), {relationship: relation(parent_type, parent_id)})
                row = api.request(f"/v1/{kind}", "POST", body)["data"]
                rows[locale] = row
            else:
                row = rows[locale]
                if any(row["attributes"].get(k) != v for k, v in attrs.items()):
                    row = api.request(f"/v1/{kind}/{row['id']}", "PATCH", payload(kind, attrs, identifier=row["id"]))["data"]
                    rows[locale] = row
            state["metadata"].setdefault(locale, {})[kind] = row["id"]
            save(checkpoint, state)
        print("Metadata registered:", locale, flush=True)
    existing_images = api.all(f"/v1/appAssetLibraries/{library}/images?limit=200")
    by_reference = {r["attributes"].get("referenceName"): r for r in existing_images}
    completed = 0
    for locale, fields in metadata["localizations"].items():
        lid = vmap[locale]["id"]
        existing_placements = api.all(f"/v1/appStoreVersionLocalizations/{lid}/placements?sort=placementGroupPosition")
        groups = {}
        for file, item in images.items():
            entry = item["entry"]
            if entry["language"] != fields["screenshotLanguage"]:
                continue
            ref = f"Kodo {metadata['version']} {locale} {entry['device']} {Path(file).stem} {entry['sha256'][:12]}"
            row = by_reference.get(ref)
            if row is None:
                attrs = {"fileName": f"{locale}-{entry['device']}-{Path(file).name}", "fileSize": entry["bytes"],
                         "category": "APP_SCREENSHOTS_AND_PREVIEWS", "referenceName": ref}
                row = api.request("/v1/appAssetLibraryImages", "POST", payload("appAssetLibraryImages", attrs,
                                  {"assetLibrary": relation("appAssetLibraries", library)}))["data"]
                by_reference[ref] = row
                state["images"][file] = {"id": row["id"], "locale": locale}
                save(checkpoint, state)
            image_id = row["id"]
            if row["attributes"]["state"] == "AWAITING_UPLOAD":
                raw = (ROOT / "screenshots" / file).read_bytes()
                for operation in row["attributes"]["uploadOperations"]:
                    headers = {h["name"]: h["value"] for h in operation["requestHeaders"]}
                    part = raw[operation["offset"]:operation["offset"] + operation["length"]]
                    request = urllib.request.Request(operation["url"], data=part, method=operation["method"], headers=headers)
                    try:
                        with urllib.request.urlopen(request, timeout=60) as response:
                            response.read()
                    except urllib.error.URLError as error:
                        raise RuntimeError(f"Asset transfer failed for {file}: {type(error).__name__}") from None
                row = api.request(f"/v1/appAssetLibraryImages/{image_id}", "PATCH", payload("appAssetLibraryImages", {"uploaded": True}, identifier=image_id))["data"]
            deadline = time.time() + 180
            while row["attributes"]["state"] in ["UPLOAD_COMPLETE", "AWAITING_UPLOAD"] and time.time() < deadline:
                time.sleep(2)
                row = api.request(f"/v1/appAssetLibraryImages/{image_id}")["data"]
            if row["attributes"]["state"] not in ["PREPARE_FOR_SUBMISSION", "APPROVED", "ACCEPTED"]:
                raise RuntimeError(f"Image processing failed: {file} {row['attributes']['state']} {row['attributes'].get('stateDetails')}")
            assert row["attributes"]["specId"] == item["spec"]
            placed = next((p for p in existing_placements if p.get("relationships", {}).get("image", {}).get("data", {}).get("id") == image_id and p["attributes"]["placementGroup"] == item["group"]), None)
            if placed is None:
                placed = api.request("/v1/appAssetLibraryPlacements", "POST", payload("appAssetLibraryPlacements",
                                     {"placementType": "APP_SCREENSHOT", "placementGroup": item["group"]},
                                     {"image": relation("appAssetLibraryImages", image_id), "appStoreVersionLocalization": relation("appStoreVersionLocalizations", lid)}))["data"]
                existing_placements.append(placed)
            state["images"][file] = {"id": image_id, "locale": locale, "state": row["attributes"]["state"], "specId": item["spec"]}
            state["placements"][file] = {"id": placed["id"], "group": item["group"], "state": placed["attributes"]["state"]}
            groups.setdefault(item["group"], []).append(placed["id"])
            save(checkpoint, state)
            completed += 1
            print(f"Screenshot registered {completed}/48: {locale} {entry['device']} {Path(file).stem}", flush=True)
        for group, ids in groups.items():
            other = [p["id"] for p in existing_placements if p["attributes"]["placementGroup"] == group and p["id"] not in ids]
            ordering = {"orderedPlacements": {"data": [{"type": "appAssetLibraryPlacements", "id": pid} for pid in other + ids]},
                        "appStoreVersionLocalization": relation("appStoreVersionLocalizations", lid)}
            api.request("/v1/appAssetLibraryPlacementOrderingRequests", "POST",
                        payload("appAssetLibraryPlacementOrderingRequests", {"placementGroup": group}, ordering))
    verify(api, metadata, manifest, app_id, vid, iid, state)


def verify(api, metadata, manifest, app_id, vid, iid, state):
    final_v = api.all(f"/v1/appStoreVersions/{vid}/appStoreVersionLocalizations")
    final_i = api.all(f"/v1/appInfos/{iid}/appInfoLocalizations")
    protected = json.loads((ROOT / "appstore/protected-locales-before.json").read_text())
    report = {"version": metadata["version"], "appId": app_id, "versionId": vid,
              "locales": {}, "protectedLocalesUnchanged": True, "submittedForReview": False}
    for kind, rows in [("version", final_v), ("info", final_i)]:
        for locale, original in protected[kind].items():
            current = next(r for r in rows if r["attributes"]["locale"] == locale)
            assert current["attributes"] == original["attributes"], f"Protected locale changed: {kind} {locale}"
    for locale, original in protected["placements"].items():
        lid = protected["version"][locale]["id"]
        current = api.all(f"/v1/appStoreVersionLocalizations/{lid}/placements?sort=placementGroupPosition")
        assert [(p["id"], p["attributes"]["placementGroup"]) for p in current] == [(p["id"], p["attributes"]["placementGroup"]) for p in original]
    for locale, fields in metadata["localizations"].items():
        vr = next(r for r in final_v if r["attributes"]["locale"] == locale)
        ir = next(r for r in final_i if r["attributes"]["locale"] == locale)
        for key in ["description", "keywords", "promotionalText", "whatsNew"]:
            assert vr["attributes"][key] == fields[key]
        for key in ["name", "subtitle"]:
            assert ir["attributes"][key] == fields[key]
        for key in ["supportUrl", "marketingUrl"]:
            assert vr["attributes"][key] == metadata["sharedUrls"][key]
        assert ir["attributes"]["privacyPolicyUrl"] == metadata["sharedUrls"]["privacyPolicyUrl"]
        placements = api.all(f"/v1/appStoreVersionLocalizations/{vr['id']}/placements?sort=placementGroupPosition")
        ours = [p for p in placements if p["id"] in {s["id"] for s in state["placements"].values()}]
        assert len(ours) == 6, (locale, len(ours))
        assert all(p["attributes"]["state"] in ["ACTIVE", "PARENT_PREPARE_FOR_SUBMISSION"] and not p["attributes"].get("stateDetails") for p in ours)
        for group in {p["attributes"]["placementGroup"] for p in ours}:
            actual = [p["id"] for p in ours if p["attributes"]["placementGroup"] == group]
            expected = [state["placements"][e["file"]]["id"] for e in manifest["screenshots"]
                        if e["language"] == fields["screenshotLanguage"] and state["placements"][e["file"]]["group"] == group]
            assert actual == expected
        report["locales"][locale] = {"name": fields["name"], "screenshots": len(ours), "placements": [p["id"] for p in ours]}
    save(ROOT / "appstore/upload-report.json", report)
    print("Verified: 8 localizations, 48 screenshot placements; Japanese and English unchanged.", flush=True)


if __name__ == "__main__":
    main()
