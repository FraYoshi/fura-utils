# Introduction
Tools that aid in the process of adding licensing metadata to artistic works.

## Examples

### all rights reserved:
`fura-reserved.sh image.png "awesome title"`

### all rights reserved with description (optional):
`fura-reserved.sh image.png "awesome title" "description of this picture"`

### batch add reserved rights to files on a directory (no title):
```
for f in *.mov; do
fura-reserved-batch.sh "$f";
done
```

for giving a title, description or license link to the file, use the batch-config file, copy the "licensing.sh" into the working directory and personalize it.

# References
- https://exiftool.org/metafiles.html
- https://exiftool.org/TagNames/XMP.html
- https://wiki.creativecommons.org/wiki/Marking_Works_Technical
- https://experienceleague.adobe.com/docs/experience-manager-65/assets/administer/metadata-concepts.html?lang=en#xmp-core-concepts
- https://github.com/adobe/xmp-docs/blob/master/XMPNamespaces/xmpRights.md
- https://www.dublincore.org/specifications/dublin-core/dcmi-terms/
