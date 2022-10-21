# OpenSCAP Standalone Install and Use

## Installing from Packages and Release ZIP

apk install openscap
apk install openscap-docs
mkdir -p /usr/share/xml/scap/ssg/content/

Fetch SCAP content from https://github.com/ComplianceAsCode/content/releases/latest/
Fetch "security-guide.zip" and unpack, will expand to 1.5 GB

cd into extract dir
mv -f * /usr/share/xml/scap/ssg/content/

Alternatively, openSCAP and security guides can be built via https://github.com/ComplianceAsCode/content.git 

## Scanning 

oscap is the main tooling and used with "xccdf eval" to execute checks. Results are provided directly on the command line and can also be compiled to a human-readable report.


Example on how to scan a RedHat Enterprise Linux 8 system:

oscap xccdf eval --fetch-remote-resources --profile xccdf_org.ssgproject.content_profile_ospp --results-arf results.xml --report report.html /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml

This uses the "fetch-remote-resources" parameter to pull any external sources and references ad-hoc, will not work on an airgapped system

## Reference URLS

[Main Page](https://github.com/OpenSCAP/openscap)

[OpenSCAP Manual](https://github.com/OpenSCAP/openscap/blob/maint-1.3/docs/manual/manual.adoc)

[Scanning containers](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/scanning-container-and-container-images-for-vulnerabilities_scanning-the-system-for-configuration-compliance-and-vulnerabilities)

[SCAP Workbench Tool to run and develop eval sets](https://www.open-scap.org/tools/scap-workbench/)
[OpenSCAP Atomic Container scanning](https://developers.redhat.com/blog/2016/05/02/introducing-atomic-scan-container-vulnerability-detection)


https://www.cisecurity.org/cis-benchmarks/	
https://static.open-scap.org/openscap-1.2/oscap_user_manual.html#_scanning_with_oscap
https://github.com/orgs/OpenSCAP/repositories
