# CI/CD dla serwera Minecraft Java w Jenkinsie z wykorzystaniem Dockera! 🚀

Podjąłem wyzwanie automatyzacji procesu wdrażania i testowania serwera Minecraft Java, używając Jenkins, Docker oraz kilku sprytnych etapów w Jenkinsfile. Poniżej znajdziecie opis całego pipeline'u, który może być pomocny dla każdego, kto chce zgłębić temat CI/CD w świecie gier!

W Jenkinsfile pipeline został podzielony na kilka etapów, z których każdy zapewnia płynność procesu:

1. **Etap Klonowanie Repozytorium** - Na początku klonujemy repozytorium, aby upewnić się, że pracujemy na najnowszej wersji kodu. To fundamentalny krok, który zapewnia, że wszystkie kolejne etapy operują na aktualnym kodzie.

2. **Etap Budowa Obrazu Docker** - Tworzymy obraz Dockera, który zawiera serwer Minecraft Java. Pobieramy bazowy obraz, konfigurujemy wszystkie wymagane zależności, a następnie budujemy nasz własny obraz Docker, który jest podstawą całej automatyzacji.

3. **Etap Testowanie Obrazu Docker** - Po zbudowaniu obrazu testujemy go, uruchamiając kontener w środowisku testowym. Dzięki temu możemy zweryfikować, czy wszystkie niezbędne pliki są obecne i czy środowisko serwera zostało prawidłowo skonfigurowane.

4. **Etap Wdrożenie do Środowiska Testowego** - Wdrażamy serwer na maszynę testową za pomocą Dockera, a Jenkins uruchamia kontener z odpowiednimi ustawieniami portów. Sprawdzamy, czy serwer uruchomił się pomyślnie, analizując logi kontenera.

5. **Etap Testy Automatyczne** - Przeprowadzamy automatyczne testy, aby upewnić się, że serwer jest dostępny i porty są odpowiednio wystawione. Te testy są kluczowe, aby potwierdzić, że wszystko działa poprawnie przed przejściem na produkcję.

6. **Etap Kopia Zapasowa Produkcji** - Przed wdrożeniem na produkcję tworzymy kopię zapasową obecnego stanu produkcyjnego, aby mieć możliwość przywrócenia danych, jeśli coś pójdzie nie tak.

7. **Etap Wdrożenie do Produkcji** - Po pomyślnym przejściu testów wdrażamy najnowszy obraz serwera do środowiska produkcyjnego, zatrzymując i zastępując istniejące kontenery. W razie potrzeby przywracamy najnowszą kopię zapasową danych świata.

8. **Etap Monitorowanie Serwera Produkcyjnego** - Na koniec monitorujemy serwer produkcyjny, upewniając się, że działa poprawnie i że porty są odpowiednio wystawione, aby zapewnić graczom płynne doświadczenie.

Cały pipeline został zaprojektowany tak, aby działał bezproblemowo zarówno lokalnie, jak i w środowiskach chmurowych, takich jak Oracle Cloud, co czyni go wszechstronnym rozwiązaniem dla różnych konfiguracji. Docker zapewnia przenośność i powtarzalność, co jest kluczowe w tym kontekście.

Zapraszam do zapoznania się z projektem w repozytorium GitHub:
https://github.com/pcmagik/ci-cd-minecraft-java-jenkins-server-game

To dopiero początek przygody z CI/CD dla serwerów gier! 🎮

#devops #jenkins #docker #cicd #minecraft #automation #oraclecloud #minecraftjava

[🇬🇧 English version of this file](README.md)