#!/bin/bash
gcloud functions deploy check-website-function-http --trigger-http --entry-point=handle_http_request \
--gen2 --allow-unauthenticated --region=${GCP_REGION} --runtime=python312 \
--set-env-vars="SETTINGS_MODULE=app.settings,GCP_PROJECT_ID=${GCP_PROJECT_ID}" \
--set-secrets "EVENTS_PUBSUB_TOPIC=projects/${GCP_PROJECT_ID}/secrets/EVENTS_PUBSUB_TOPIC:latest,CSFU_HTTP_HEADER_VALUE=projects/${GCP_PROJECT_ID}/secrets/CSFU_HTTP_HEADER_VALUE:latest,CSFU_TARGETS=projects/${GCP_PROJECT_ID}/secrets/CSFU_TARGETS:latest,CSFU_WEBHOOK_URL=projects/${GCP_PROJECT_ID}/secrets/CSFU_WEBHOOK_URL:latest,CSFU_PROXY=projects/${GCP_PROJECT_ID}/secrets/CSFU_PROXY:latest" \
&

gcloud functions deploy check-website-function-events --trigger-topic=hourly-trigger --entry-point=handle_event \
--service-account=check-site-update-function@municipal-fairs.iam.gserviceaccount.com \
--gen2 --region=${GCP_REGION} --runtime=python312 \
--set-env-vars="SETTINGS_MODULE=app.settings,GCP_PROJECT_ID=${GCP_PROJECT_ID}" \
--set-secrets "EVENTS_PUBSUB_TOPIC=projects/${GCP_PROJECT_ID}/secrets/EVENTS_PUBSUB_TOPIC:latest,CSFU_HTTP_HEADER_VALUE=projects/${GCP_PROJECT_ID}/secrets/CSFU_HTTP_HEADER_VALUE:latest,CSFU_TARGETS=projects/${GCP_PROJECT_ID}/secrets/CSFU_TARGETS:latest,CSFU_WEBHOOK_URL=projects/${GCP_PROJECT_ID}/secrets/CSFU_WEBHOOK_URL:latest,CSFU_PROXY=projects/${GCP_PROJECT_ID}/secrets/CSFU_PROXY:latest"
