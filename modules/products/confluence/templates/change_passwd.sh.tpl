login_xml=$(cat <<XML_CONTENTS
<?xml version="1.0"?>
<methodCall>
    <methodName>confluence2.login</methodName>
    <params>
        <param>
        <value>admin</value>
        </param>
        <param>
        <value>admin</value>
        </param>
    </params>
</methodCall>
XML_CONTENTS
)
echo "[INFO]: Getting auth token using existing credentials..."

token=$(curl -s -H "Content-Type: application/xml" --data "$login_xml" ${url}/rpc/xmlrpc | awk -F"[<>]" '{ print $11 }')

if [ -z "$token" ]; then
    echo "[ERROR]: Failed to retrieve auth token. The response was:"
    curl -v -H "Content-Type: application/xml" --data "$login_xml" ${url}/rpc/xmlrpc
    exit 1
else
    echo "[INFO]: Auth token successfully retrieved"
fi

pwd_change=$(cat <<XML_CONTENTS
<?xml version="1.0"?>
<methodCall>
    <methodName>confluence2.changeMyPassword</methodName>
    <params>
        <param>
        <value>$token</value>
        </param>
        <param>
        <value>admin</value>
        </param>
        <param>
        <value>${newPassword}</value>
        </param>
    </params>
</methodCall>
XML_CONTENTS
)

echo "[INFO]: Updating admin password..."

STATUS=$(curl -s -o /dev/null -w '%%{http_code}' -H "Content-Type: application/xml" --data "$pwd_change" ${url}/rpc/xmlrpc)
if [ $STATUS -ne 200 ]; then
    echo "[ERROR]: Failed to update password. Response code was $STATUS:"
    curl -v -H "Content-Type: application/xml" --data "$pwd_change" ${url}/rpc/xmlrpc
    exit 1
else
    echo "[INFO]: Password successfully changed"
fi

