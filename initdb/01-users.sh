#!/bin/sh
# Usuarios de prueba: uno por método de autenticación que soporta pgsal.
set -e
psql -v ON_ERROR_STOP=1 -U postgres -d pgsal <<SQL
SET password_encryption = 'md5';
CREATE ROLE sal_md5 LOGIN PASSWORD 'md5pass' SUPERUSER;
SET password_encryption = 'scram-sha-256';
CREATE ROLE sal_scram LOGIN PASSWORD 'scrampass' SUPERUSER;
CREATE ROLE sal_trust LOGIN SUPERUSER;
CREATE ROLE sal_plain LOGIN PASSWORD 'plainpass' SUPERUSER;
SQL
# pg_hba: sal_trust sin contraseña, sal_md5 con md5, el resto con scram-sha-256.
HBA="$PGDATA/pg_hba.conf"
{
  echo "host all sal_trust all trust"
  echo "host all sal_md5   all md5"
  echo "host all sal_plain all password"
  cat "$HBA"
} > "$HBA.new"
mv "$HBA.new" "$HBA"
