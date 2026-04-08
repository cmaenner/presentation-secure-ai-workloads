"""Untrusted client — exists for kubectl exec during the demo."""

import time

if __name__ == "__main__":
    print("[untrusted-client] Ready. Use kubectl exec to run curl commands.")
    while True:
        time.sleep(3600)
