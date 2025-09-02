#!/usr/bin/env bash

# Sign kernel image and any associated Unified Kernel Image with all keys under the specified system-wide path. 

KEYCHAIN_PATH="/usr/share/secureboot/keychain"

[ ! -d "$KEYCHAIN_PATH" ] && printf "keychain directory not found: %s\n" "$KEYCHAIN_PATH" && exit 1

preset_kernel="$(awk -F'-' '{ print $1 }' - <<< ${MKINITCPIO_PROCESS_PRESET})"
preset_name="$(awk -F'-' '{ print $2 }' - <<< ${MKINITCPIO_PROCESS_PRESET})"

function option() {
  grep -Po "^(${preset_name}|ALL)_${1}=(\K.*)$" "/etc/mkinitcpio.d/${preset_kernel}.preset"  | tr -d '"'
}

kver_path="$(option "kver")"
uki_path="$(option "uki")"

echo "Signature Targets:" "$kver_path" "$uki_path"

function sign() {
  target_file=$1
  target_certificate=$2
  target_private_key=$3

  if ! sbverify --cert "$target_certificate" "$target_file" >/dev/null 2>&1; then
    echo "Signing $target_file with $target_certificate"
    sbsign --key "$target_private_key" --cert "$target_certificate" --output "$target_file" "$target_file"
  else
    echo "$target_file already signed with $target_certificate"
  fi
}

for base in $(for f in "$KEYCHAIN_PATH"/*.{cer,crt,key}; do [ -f "$f" ] && basename "$f" | cut -d. -f1; done | sort -u); do
  cert="$KEYCHAIN_PATH/$base.cer"
  crt="$KEYCHAIN_PATH/$base.crt"
  key="$KEYCHAIN_PATH/$base.key"

  # require all three files to be present
  if [[ -f "$cert" && -f "$crt" && -f "$key" ]]; then
    echo "Processing keychain: $base"
    sign "$kver_path" "$crt" "$key"
    sign "$uki_path"  "$crt" "$key"
  else
    echo "Skipping $base (missing one of .cer, .crt, .key)"
  fi
done
