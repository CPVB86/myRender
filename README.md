# myRender — Raspberry Pi-infrastructuur

Docker-/Compose-installatie voor de Discord-bot Knippie op een ARM64 Raspberry Pi. De botcode staat afzonderlijk in [kt-academy/bot](https://github.com/CPVB86/kt-academy/tree/main/bot). Deze repository bevat uitsluitend infrastructuur en voorbeeldinstellingen, geen tokens of gebruikersdata.

## Indeling

```text
MyRender/
  compose.yaml
  Dockerfile
  config/knippie.env          # lokaal, buiten Git
  config/knippie.env.example
  apps/kt-academy/            # aparte Git-checkout, buiten deze repository
    bot/
```

De projectnaam blijft `myrender`, de service `knippie` en het datavolume `myrender_knippie-data`. Daardoor kunnen bestaande gegevens bij een bewuste overstap naar deze indeling behouden blijven. De huidige Pi-installatie wordt door het pushen naar GitHub niet gewijzigd.

## Nieuwe installatie

De bestaande Docker-service en Docker Compose worden gebruikt. Voer geen upgrades, prune, autoremove of wijzigingen aan Backyard uit voor deze installatie.

**Let op:** bestaat `~/MyRender` al met de eerdere losse bestanden, clone daar niet overheen. Bereid deze indeling eerst in een nieuwe map voor, neem je bestaande `config/knippie.env` privé over en controleer de instellingen vóór het vervangen van de bestaande container. Draai geen tweede Knippie tegelijk.

Voor een nieuwe doelmap:

```bash
git clone https://github.com/CPVB86/myRender.git ~/MyRender
cd ~/MyRender
mkdir -p apps
git clone https://github.com/CPVB86/kt-academy.git apps/kt-academy
chmod 700 config
test -e config/knippie.env || (umask 077; cp config/knippie.env.example config/knippie.env)
chmod 600 config/knippie.env
nano config/knippie.env
```

Wanneer kt-academy privé is moet de Pi daarvoor Git-leestoegang hebben. Zet geen toegangstoken in de Git-URL of in deze repository.

Vul een **eigen Knippie-token**, application-ID, server-ID en de rol-ID’s in. Het pollkanaal is `1564343167896256612`. Token en application-ID moeten bij dezelfde Discord-application horen. De oude bots worden niet gebruikt.

```bash
sudo docker-compose build
sudo docker-compose run --rm --no-deps knippie node src/deploy.js
sudo docker-compose up -d knippie
sudo docker-compose logs --tail=30 knippie
```

De planning wordt actief zodra Knippie start. Na maandag 08:30 kan meteen de poll voor de lopende week verschijnen. Er is geen extra cronjob nodig. Privileged Discord-intents en een Interactions Endpoint URL zijn niet nodig.

## Discord-kanaalrechten

Gebruik één gewoon tekstkanaal. Stel via roloverschrijvingen in:

| Recht | @everyone | basic | premium | Knippie |
| --- | --- | --- | --- | --- |
| Kanaal bekijken | Weigeren | Toestaan | Toestaan | Toestaan |
| Berichtgeschiedenis lezen | Neutraal | Toestaan | Toestaan | Toestaan |
| Berichten verzenden in hoofdkanaal | Weigeren | Weigeren | Weigeren | Toestaan |
| Openbare threads maken | Weigeren | Weigeren | Weigeren | Toestaan |
| Privéthreads maken | Weigeren | Weigeren | Weigeren | Niet nodig |
| Berichten in threads verzenden | Weigeren | Weigeren | Toestaan | Toestaan |
| Threads beheren | Weigeren | Weigeren | Weigeren | Toestaan |

Beheerders omzeilen kanaalbeperkingen. Andere rol-/lidoverschrijvingen kunnen extra rechten geven; test met gewone ledenaccounts. Knippie verandert geen rollen/rechten. Basic-leden zien de discussie maar kunnen niet reageren. Premium krijgt voorrang bij beide rollen. Threads worden na zeven etmalen vergrendeld en gearchiveerd, zodat gewone leden niet kunnen heropenen. Discords eigen autoarchivering is geen vaste sluitingsdeadline.

## Updates

```bash
cd ~/MyRender
git pull --ff-only
git -C apps/kt-academy pull --ff-only
sudo docker-compose build
sudo docker-compose run --rm --no-deps knippie node src/deploy.js
sudo docker-compose up -d knippie
sudo docker-compose logs --tail=30 knippie
```

De bot en infrastructuur hebben elk een eigen Git-historie. WordPress-bestanden naast `bot/` worden niet naar het botimage gekopieerd. Tokens, logs en data worden niet naar Git gepusht.

## Beheer en gegevens

Vanuit deze projectmap: `sudo docker-compose stop knippie` stopt bewust; `sudo docker-compose restart knippie` herstart. De container herstart na een crash of Pi-reboot via de bestaande Docker-service en `unless-stopped`. Een bewust gestopte container blijft gestopt.

Geen open hostpoorten of bestaande netwerken nodig. Eigen standaardnetwerk `myrender_default` en volume `myrender_knippie-data`. CPU-limiet 0,5 en geheugenlimiet 256 MB zijn ingesteld; op de huidige Pi meldt Docker dat de geheugenlimiet niet afgedwongen kan worden. Er worden geen kernel-/systeeminstellingen aangepast. Docker-images en volumes staan in Dockers opslag; botprocessen gebruiken gedeelde Pi-resources.

Gebruik geen `down -v` of Docker-prune: behoud het volume met quiz-, poll- en planningsgegevens. Maak voor een verhuizing een privéback-up van het volume en env-bestand. Draai slechts één Knippie-container. `~/Backyard` wordt niet benaderd.
