locals {
  namespace = "monitoring"

  kibana_import = <<EOT
#!/bin/bash
# Import a dashboard
KB_URL=http://localhost:5601
while [[ "$(curl -s -o /dev/null -w '%\{http_code\}\n' -L $KB_URL)" != "200" ]]; do sleep 1; done
curl -XPOST "$KB_URL/api/kibana/dashboards/import" -H "Content-Type: application/json" -H 'kbn-xsrf: true' -d'{"objects":[{"type":"index-pattern","id":"my-pattern","attributes":{"title":"bamboo-*"}},{"type":"dashboard","id":"my-dashboard","attributes":{"title":"Look at my dashboard"}}]}'
EOT
}