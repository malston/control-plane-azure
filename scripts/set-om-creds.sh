# shellcheck shell=sh
OM_TARGET=$(terraform output -state="${STATE_FILE}" ops_manager_dns)
export OM_TARGET
OM_USERNAME=$(terraform output -state="${STATE_FILE}" ops_manager_username)
export OM_USERNAME
OM_PASSWORD=$(terraform output -state="${STATE_FILE}" ops_manager_password)
export OM_PASSWORD
OM_DECRYPTION_PASSPHRASE=$(terraform output -state="${STATE_FILE}" ops_manager_decryption_phrase)
export OM_DECRYPTION_PASSPHRASE
