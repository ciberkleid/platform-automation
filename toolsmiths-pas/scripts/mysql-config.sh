#!/bin/bash -e
PIVNET_TOKEN=$1
version=$(bosh interpolate ../config/versions/mysql.yml --path /product-version)
glob=$(bosh interpolate ../config/versions/mysql.yml --path /pivnet-file-glob)
slug=$(bosh interpolate ../config/versions/mysql.yml --path /pivnet-product-slug)

mkdir -p mysql-tcg
tmpdir=mysql-tcg
tile-config-generator generate --base-directory=${tmpdir} --do-not-include-product-version --include-errands pivnet --token ${PIVNET_TOKEN} --product-slug ${slug} --product-version ${version} --product-glob ${glob}
#bosh int ${tmpdir}/product.yml \
#  -o ${tmpdir}/features/haproxy_forward_tls-disable.yml \
#  -o ${tmpdir}/optional/add-control-static_ips.yml \
#  -o ${tmpdir}/optional/add-router-static_ips.yml \
#   > ../config/templates/mysql.yml

cat ${tmpdir}/product.yml > ../config/templates/mysql.yml

rm -rf ../config/defaults/mysql.yml
touch ../config/defaults/mysql.yml
cat ${tmpdir}/product-default-vars.yml >> ../config/defaults/mysql.yml
cat ${tmpdir}/errand-vars.yml >> ../config/defaults/mysql.yml
cat ${tmpdir}/resource-vars.yml >> ../config/defaults/mysql.yml
