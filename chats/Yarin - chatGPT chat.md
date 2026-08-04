🧑 - Hey chat! I created a GitHub repository and tried creating a Docker network called `first`. It only appeared locally. How do I make other people use that network?

🤖 - Docker networks are local to each Docker installation. They are not uploaded to GitHub. Every person who runs the project must create the network on their own computer, or the project should create it automatically through a script or Docker Compose.

```bash
docker network create first
```

🧑 - I created PostgreSQL with this command:

```bash
docker run --name some-postgres -e POSTGRES_PASSWORD=my-secret-pw -d postgres
```

🤖 - That created PostgreSQL inside Docker, but it did not expose port `5432` to the host computer. The command needs:

```bash
-p 5432:5432
```

A complete command is:

```bash
docker run --name some-postgres   -e POSTGRES_PASSWORD=my-secret-pw   -p 5432:5432   -d postgres:latest
```

🧑 - According to the assignment, I need a Docker network, PostgreSQL, and Drupal. I want to do everything simply.

🤖 - Create the Docker network:

```bash
docker network create first
```

Pull the latest PostgreSQL image:

```bash
docker pull postgres:latest
```

Run PostgreSQL:

```bash
docker run --name first-postgres   --network first   -e POSTGRES_PASSWORD=my-secret-pw   -p 5432:5432   -d postgres:latest
```

Check that it is running and connected to the network:

```bash
docker ps
docker network inspect first
```

🧑 - How do I create another container for Drupal?

🤖 - Pull the latest official Drupal image:

```bash
docker pull drupal:latest
```

Create the Drupal container on the same network:

```bash
docker run --name first-drupal   --network first   -p 8080:80   -d drupal:latest
```

Check that both containers are running:

```bash
docker ps
```

You should see:

```text
first-postgres
first-drupal
```

Then open Drupal in the browser:

```text
http://localhost:8080
```

🧑 - I checked the network, and only Drupal appeared inside `first`. PostgreSQL was missing.

🤖 - Connect the existing PostgreSQL container to the network:

```bash
docker network connect first first-postgres
```

Then check again:

```bash
docker network inspect first
```

Both `first-postgres` and `first-drupal` should now appear under `Containers`.

🧑 - Now I have a PostgreSQL container called `first-postgres` and a Drupal container called `first-drupal`.

🤖 - Good. Drupal can now communicate with PostgreSQL by using `first-postgres` as the database host.

🧑 - PostgreSQL has a volume, but Drupal does not show anything under `Mounts`. Is that a problem?

🤖 - PostgreSQL having a volume is the most important part for keeping the database data. It is still safer to give Drupal a volume too, because it preserves Drupal files and configuration when the container is recreated.

Create a Drupal volume:

```bash
docker volume create drupal-data
```

Stop and remove only the Drupal container:

```bash
docker stop first-drupal
docker rm first-drupal
```

Run Drupal again with the volume:

```bash
docker run --name first-drupal   --network first   -p 8080:80   -v drupal-data:/var/www/html   -d drupal:latest
```

Check it:

```bash
docker inspect first-drupal
```

Under `Mounts`, the destination should include:

```text
/var/www/html
```

🧑 - Drupal asks me to select an installation profile. Should I choose Standard?

🤖 - Yes. Choose `Standard`, then click `Save and continue`.

🧑 - Drupal now asks for database configuration. What should I enter?

🤖 - Choose PostgreSQL and enter:

```text
Database name: postgres
Database username: postgres
Database password: my-secret-pw
```

Under `Advanced options`, enter:

```text
Host: first-postgres
Port: 5432
```

Use `first-postgres`, not `localhost`, because Drupal and PostgreSQL are separate containers.

🧑 - Drupal now shows the Configure Site page. Do I need specific account details?

🤖 - The assignment requires this Drupal administrator account:

```text
Username: demoadmin
Password: secretpass
```

The site name should include the team members' names, for example:

```text
The site of Yarin and [teammate name]
```

The assignment does not require a specific email address, so a personal or school email can be used.

🧑 - The website was created successfully. What else do I need to do?

🤖 - The remaining task in this section is to create a regular Drupal user account for each team member through:

```text
People → Add user
```

🧑 - Will the website stay available, or will I need to configure it again?

🤖 - Closing the browser or terminal does not delete the website. The data remains as long as the containers and volumes are not deleted.

To make the containers start automatically when Docker Desktop starts:

```bash
docker update --restart unless-stopped first-postgres
docker update --restart unless-stopped first-drupal
```

To start them manually later:

```bash
docker start first-postgres
docker start first-drupal
```

Then open:

```text
http://localhost:8080
```

🧑 - Part 4 asks us to back up the database. I know the container name, but I do not remember the database name.

🤖 - The database name used during Drupal installation was `postgres`.

You can verify it with:

```bash
docker exec -it first-postgres psql -U postgres -l
```

Create the backup from the repository directory:

```bash
docker exec first-postgres pg_dump -U postgres -d postgres > drupal-database-backup.sql
```

On PowerShell, use this to avoid encoding problems:

```powershell
cmd /c "docker exec first-postgres pg_dump -U postgres -d postgres > drupal-database-backup.sql"
```

Check that the file exists:

```powershell
dir drupal-database-backup.sql
```

The backup should contain PostgreSQL statements such as:

```sql
SET
CREATE TABLE
CREATE INDEX
COPY
ALTER TABLE
```

🧑 - The backup file was created successfully.

🤖 - Add it to the repository if the assignment requires it:

```bash
git add drupal-database-backup.sql
git commit -m "Add PostgreSQL database backup"
git push
```

🧑 - Do we need to push the backup and test it on a Linux VM?

🤖 - Yes. The purpose is to prove that the backup can restore the database on another machine.

On the Linux VM, clone or update the repository:

```bash
git clone <repository-url>
```

or:

```bash
git pull
```

Enter the repository directory:

```bash
cd <repository-folder>
```

Create the network:

```bash
docker network create first
```

Create a clean PostgreSQL container:

```bash
docker run --name first-postgres   --network first   -e POSTGRES_PASSWORD=my-secret-pw   -p 5432:5432   -d postgres:latest
```

Copy the backup into the container:

```bash
docker cp drupal-database-backup.sql first-postgres:/backup.sql
```

Restore it:

```bash
docker exec -i first-postgres   psql -U postgres -d postgres -f /backup.sql
```

🧑 - The restore printed many `CREATE INDEX` lines. What now?

🤖 - That is a good sign. PostgreSQL is rebuilding the database structure.

Check that the tables exist:

```bash
docker exec -it first-postgres   psql -U postgres -d postgres -c "\dt"
```

You can also list the public tables:

```bash
docker exec -it first-postgres   psql -U postgres -d postgres   -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;"
```

Check that Drupal data exists:

```bash
docker exec -it first-postgres   psql -U postgres -d postgres   -c "SELECT COUNT(*) FROM users_field_data;"
```

If it returns a number instead of an error, the Drupal data was restored.

🧑 - The database restored in the Linux VM, but how does that help with the website?

🤖 - Restoring PostgreSQL restores the website's data, users, configuration, and content, but Drupal itself must also be running and connected to that database.

The Linux VM needs both containers on the same network:

```text
first-postgres
first-drupal
network: first
```

Create Drupal:

```bash
docker run --name first-drupal   --network first   -p 8080:80   -d drupal:latest
```

Drupal also needs the restored `settings.php` file and uploaded files. The important paths are:

```text
/var/www/html/sites/default/settings.php
/var/www/html/sites/default/files
```

After restoring the database and Drupal files, restart Drupal:

```bash
docker restart first-drupal
```

Then open:

```text
http://localhost:8080
```

If the original website and its content appear, the restoration was successful.

🧑 - I have scripts such as `backup.sh`, `cleanup.sh`, `restore.sh`, and `setup.sh`. I want Git to preserve their execute permission so anyone who clones the project can run them.

🤖 - First give the scripts execute permission:

```bash
chmod +x backup.sh cleanup.sh restore.sh setup.sh
```

Then tell Git to store the executable bit:

```bash
git update-index --chmod=+x backup.sh
git update-index --chmod=+x cleanup.sh
git update-index --chmod=+x restore.sh
git update-index --chmod=+x setup.sh
```

Commit and push:

```bash
git add backup.sh cleanup.sh restore.sh setup.sh
git commit -m "Make shell scripts executable"
git push
```

🧑 - I checked with:

```bash
git ls-files --stage *.sh
```

and every file starts with `100755`. Does that mean they have execute permission?

🤖 - Yes.

```text
100644 = regular file without execute permission
100755 = regular executable file
```

Therefore these scripts are correctly marked as executable:

```text
backup.sh
cleanup.sh
restore.sh
setup.sh
```

After cloning on Linux, they can be run with:

```bash
./setup.sh
./backup.sh
./restore.sh
./cleanup.sh
```

🧑 - The scripts run fine. I checked them with my friends and they work.

🤖 - Great. The final project setup is:

```text
Docker network: first
PostgreSQL container: first-postgres
Drupal container: first-drupal
PostgreSQL port: 5432
Drupal port mapping: 8080:80
Database name: postgres
Database username: postgres
Database password: my-secret-pw
Drupal admin username: demoadmin
Drupal admin password: secretpass
```

The project now supports Docker setup, Drupal and PostgreSQL containers, a shared network, persistent data, backup, restoration on Linux, website restoration using `settings.php`, and executable automation scripts.
