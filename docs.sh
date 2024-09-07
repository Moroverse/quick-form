swift package \
    --allow-writing-to-directory ./docs \
    generate-documentation --target QuickForm \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path quick-form \
    --output-path ./docs
