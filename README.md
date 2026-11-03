# pgsal

Cliente PostgreSQL en [sal](../sal) puro: protocolo v3 sobre los sockets de `std/io`, sin librerías C.

```sal
import "pgsal/pg.sal"

fn main() -> Int ! io, alloc
    c = pg_connect("127.0.0.1", 5432, "postgres", "secreto", "mibd")
    if pg_conn_ok(c) == 0
        return 1                                   # pg_conn_error(c) dice por qué
    r = pg_query(c, "SELECT id, nombre FROM t")
    i = 0
    while i < pg_rows(r)
        print_str(pg_get(r, i, 1))
        i = i + 1
    ps = sk_sl_new()
    x = sk_sl_push(ps, "Ana")
    r2 = pg_query_params(c, "SELECT * FROM t WHERE nombre = $1", ps)
    x = pg_close(c)
    0
```

## API

| Función | Qué hace |
|---|---|
| `pg_connect(host, port, user, password, db)` → `PgConn` | conecta y autentica; `pg_conn_ok`, `pg_conn_error` |
| `pg_query(c, sql)` → `PgResult` | protocolo simple (varias sentencias; devuelve la última) |
| `pg_query_params(c, sql, ps)` → `PgResult` | protocolo extendido con `$1…`; `ps` es una lista `sk_sl_*`; `pg_null()` envía NULL |
| `pg_exec(c, sql)` → `String` | sentencia sin resultado; `""` si ok, si no el error |
| `pg_ok`, `pg_error`, `pg_tag`, `pg_affected` | estado del resultado |
| `pg_rows`, `pg_cols`, `pg_col_name`, `pg_get`, `pg_get_int`, `pg_is_null` | acceso a celdas (todo llega como texto) |
| `pg_quote`, `pg_quote_ident` | escapado para el protocolo simple |
| `pg_close(c)` | envía Terminate y cierra |

Autenticación: `trust`, contraseña en claro, `md5` y `SCRAM-SHA-256`. Sin TLS, `COPY`, ni tipos binarios.

## Tests

```bash
./test.sh                 # docker compose up + sal test + docker compose down -v
# o a mano:
docker compose up -d --wait && sal install && sal test
```

El compose (`postgres:16-alpine`, puerto `127.0.0.1:55432`) crea usuarios `sal_md5`, `sal_plain`, `sal_trust` y `sal_scram` para probar cada método (`initdb/01-users.sh`).
