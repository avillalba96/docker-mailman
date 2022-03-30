# Docker Mailman

All in one Docker image for GNU
[Mailman](http://www.gnu.org/software/mailman/index.html).

## **Install:**

```bash
git clone https://github.com/avillalba96/docker-mailman.git
cd docker-mailman
#edit env
docker-compose --compatibility up -d; docker-compose logs -ft --tail=35
```

## **Use:**

* Web site:

```bash
localhost:8080/listinfo
```

* Generate list:

1. *before, generate the list from the web*

2. Exec

```bash
docker exec -it mailman sh -c "/usr/lib/mailman/bin/genaliases -q > /etc/aliases.mailman && newaliases"
```

* Test list

```bash
docker exec -it mailman sh -c "mail -s 'Test' list@example.com < '/etc/hosts'"
```

* Del list:

```bash
docker exec -it mailman sh -c "/usr/lib/mailman/bin/rmlist -a LIST"
docker exec -it mailman sh -c "/usr/lib/mailman/bin/genaliases -q > /etc/aliases.mailman && newaliases"
```

* Migrate mailman:

```bash
rsync -avz /var/lib/mailman/lists user@docker-server:/PATH/mailman-cfg/lib/mailman
rsync -avz /var/lib/mailman/archives user@docker-server:/PATH/mailman-cfg/lib/mailman
#rsync -avz /var/lib/mailman/data user@docker-server:/PATH/mailman-cfg/lib/mailman
```

```bash
docker exec -it mailman sh -c "/usr/lib/mailman/bin/genaliases -q > /etc/aliases.mailman && newaliases"
docker exec -it mailman sh -c "/usr/lib/mailman/bin/withlist -l -r fix_url LIST -u NEW_URL"
```

## **Environment Configs:**

* `MAILMAN_URLHOST` - Mailman url host eg `www.example.com:8080`
* `MAILMAN_EMAILHOST` - Mailman email host eg `example.com`
* `MAILMAN_ADMINMAIL` - Mailman administrator email address eg `admin@example.com`
* `MAILMAN_ADMINPASS` - Mailman administrator password
* `MAILMAN_LANGUAGE` - Mailman language

SSL options for opportunistic SMTP TLS:

* `MAILMAN_SSL_CRT` - SSL Certificate (optional)
* `MAILMAN_SSL_KEY` - SSL Key (optional)
* `MAILMAN_SSL_CA` - SSL CA (optional)

## **Source:**

<https://github.com/macropin/docker-mailman>
