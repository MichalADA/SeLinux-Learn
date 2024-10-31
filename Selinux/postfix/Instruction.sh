#Projekt: Konfiguracja i zabezpieczenie serwera pocztowego Postfix z SELinux w trybie lokalnym

# Kroki projektu
# Instalacja serwera pocztowego Postfix

# Zainstaluj Postfix, który będzie pełnił rolę serwera pocztowego:


sudo dnf install -y postfix


# Konfiguracja Postfix do działania lokalnego

# Skonfiguruj Postfix tak, aby działał tylko lokalnie, co pozwala na wysyłanie i odbieranie poczty między użytkownikami na tym samym serwerze:

# Otwórz plik konfiguracyjny Postfix:


sudo nano /etc/postfix/main.cf

# Zmodyfikuj konfigurację w pliku main.cf, aby ustawić Postfix w tryb lokalny:


myhostname = localhost
mydomain = localdomain
myorigin = $mydomain
inet_interfaces = loopback-only
mydestination = $myhostname, localhost.$mydomain, localhost
home_mailbox = Maildir/
myhostname: Ustaw na localhost 

mydomain: Ustaw na localdomain lub pozostaw domyślną wartość.

inet_interfaces = loopback-only: Umożliwia działanie Postfix tylko na lokalnym interfejsie (127.0.0.1).

mydestination: Definiuje lokalne nazwy hostów.

# Uruchomienie i włączenie Postfix

# Po dokonaniu zmian, uruchom Postfix i ustaw go na automatyczny start:


sudo systemctl start postfix
sudo systemctl enable postfix

# Ustawienie kontekstu SELinux dla katalogów pocztowych

# Upewnij się, że katalogi pocztowe użytkowników mają odpowiedni kontekst SELinux. 
# Postfix przechowuje pocztę w formacie Maildir, który wymaga ustawienia kontekstu mail_spool_t w katalogach domowych użytkowników.

# Stwórz katalog poczty w domowym katalogu użytkownika:

sudo mkdir -p /home/username/Maildir
sudo chown username:username /home/username/Maildir
sudo semanage fcontext -a -t mail_spool_t "/home/username/Maildir(/.*)?"
sudo restorecon -R /home/username/Maildir

# Dostosowanie SELinux dla Postfix

# SELinux oferuje kilka booleanów, które są przydatne w pracy z Postfixem. Oto dwa ważne:

allow_postfix_local_write_mail_spool: Pozwala Postfixowi na zapisywanie poczty lokalnie.
postfix_local_write_mail_spool: Zezwala Postfixowi na lokalne zapisywanie poczty w katalogu Maildir.

# Włącz te booleany:


sudo setsebool -P allow_postfix_local_write_mail_spool 1
sudo setsebool -P postfix_local_write_mail_spool 1
# Wysyłanie testowego e-maila

# Użyj polecenia mail, aby wysłać testowy e-mail do lokalnego użytkownika:


echo "Testowy e-mail" | mail -s "Test" username


# Monitorowanie naruszeń SELinux

# Jeśli Postfix napotka problemy z dostępem, sprawdź logi SELinux, aby zidentyfikować potencjalne blokady:

sudo ausearch -m avc -c postfix