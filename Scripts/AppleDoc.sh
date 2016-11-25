/usr/local/bin/appledoc \
--project-name "${PROJECT_NAME}" \
--project-company "Skylable" \
--company-id "com.Skylable" \
--install-docset \
--logformat xcode \
--keep-undocumented-objects \
--keep-undocumented-members \
--keep-intermediate-files \
--no-repeat-first-par \
--no-warn-invalid-crossref \
--exit-threshold 2 \
--docset-platform-family iphoneos \
--ignore "*.m" \
--ignore "${PROJECT_DIR}/DocumentManagerTests" \
"${BUILT_PRODUCTS_DIR}/${PUBLIC_HEADERS_FOLDER_PATH}"
