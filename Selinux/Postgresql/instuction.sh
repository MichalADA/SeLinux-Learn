# Instrukcja: Konfiguracja i zabezpieczenie serwera PostgreSQL przy użyciu SELinux

# 1. Instalacja PostgreSQL
# Zainstaluj PostgreSQL:

sudo dnf install -y postgresql-server postgresql-contrib
# 2. Inicjalizacja bazy danych
# Zainicjuj bazę danych PostgreSQL:

sudo postgresql-setup --initdb

# 3. Uruchomienie i włączenie PostgreSQL
# Uruchom PostgreSQL i ustaw go na automatyczny start przy starcie systemu:


sudo systemctl start postgresql
sudo systemctl enable postgresql


# 4. Zmiana lokalizacji danych PostgreSQL 
# Jeśli chcesz przechowywać dane PostgreSQL w niestandardowej lokalizacji (np. /srv/postgresql):

# Stwórz katalog:


sudo mkdir -p /srv/postgresql
sudo chown postgres:postgres /srv/postgresql


# Skopiuj istniejące dane do nowej lokalizacji:


sudo rsync -av /var/lib/pgsql/data/ /srv/postgresql/
# Zaktualizuj plik konfiguracyjny PostgreSQL, aby wskazywał na nową lokalizację danych. 
# Otwórz /var/lib/pgsql/data/postgresql.conf i zmień wartość data_directory:


data_directory = '/srv/postgresql'


# Zastosuj zmiany w SELinux dla nowego katalogu.
# Przypisz kontekst postgresql_db_t do katalogu:


sudo semanage fcontext -a -t postgresql_db_t "/srv/postgresql(/.*)?"
sudo restorecon -R /srv/postgresql


# 5. Ustawienia SELinux dla PostgreSQL
# SELinux oferuje booleany, które mogą być przydatne przy pracy z PostgreSQL. Oto najważniejsze:

postgresql_can_rsync – Pozwala na synchronizację danych PostgreSQL za pomocą rsync.
postgresql_can_network_connect_db – Umożliwia PostgreSQL nawiązywanie połączeń z innymi bazami danych przez sieć.
postgresql_selinux_transmit_client_label – Zezwala na przesyłanie etykiet SELinux klienta w połączeniach PostgreSQL.


# Aby włączyć boolean umożliwiający zdalne połączenia, użyj:


sudo setsebool -P postgresql_can_network_connect_db 1


# 6. Dostosowanie zapory sieciowej dla PostgreSQL
# Jeśli chcesz umożliwić zdalny dostęp, otwórz port 5432 (domyślny port PostgreSQL):


sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --reload


# 7. Tworzenie bazy danych i testowanie konfiguracji
# Zaloguj się do PostgreSQL jako użytkownik postgres:


sudo -i -u postgres psql
# Utwórz nową bazę danych i tabelę, a następnie wstaw przykładowe dane:

# sql

# CREATE DATABASE testdb;
# \c testdb
# CREATE TABLE test_table (id SERIAL PRIMARY KEY, data TEXT);
# INSERT INTO test_table (data) VALUES ('SELinux test data');
# SELECT * FROM test_table;
# Wyjdź z PostgreSQL:

# sql

# \q


# 8. Monitorowanie naruszeń SELinux
# Jeśli wystąpią problemy z dostępem PostgreSQL, sprawdź logi SELinux, aby zidentyfikować ewentualne naruszenia:


sudo ausearch -m avc -c postgresql
# Możesz też użyć audit2why, aby uzyskać więcej informacji na temat błędów:


sudo ausearch -m avc -c postgresql | audit2why


# 9. Tworzenie wyjątków SELinux (jeśli to konieczne)
# Jeśli SELinux blokuje niektóre działania PostgreSQL, możesz stworzyć niestandardowy moduł polityki:


sudo ausearch -c postgresql | audit2allow -M postgresql_custom_policy
sudo semodule -i postgresql_custom_policy.pp
