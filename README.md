# Habitracker

Habitracker é um aplicativo móvel desenvolvido em Flutter que ajuda os usuários a construir e manter hábitos saudáveis, transformando a jornada de autodesenvolvimento em uma experiência recompensadora e divertida.

## 📱 Visão Geral

O Habitracker é uma ferramenta completa para gerenciamento de hábitos que permite:
- Acompanhar hábitos diários, semanais e mensais
- Visualizar progresso com gráficos e estatísticas
- Receber lembretes e notificações
- Estabelecer metas e recompensas
- Acompanhar rotinas e criar checklists

## 🛠️ Tecnologias Utilizadas

- **Framework**: Flutter (Dart)
- **Backend**: Firebase
  - Autenticação (Firebase Auth)
  - Banco de Dados (Cloud Firestore)
  - Armazenamento (Firebase Storage)
- **Gerenciamento de Estado**: Provider
- **UI/UX**: Material Design 3
- **Outras Bibliotecas**:
  - fl_chart: Para visualização de dados
  - shared_preferences: Para armazenamento local
  - flutter_local_notifications: Para notificações locais
  - image_picker: Para upload de imagens
  - google_sign_in: Para autenticação com Google

## 📂 Estrutura do Projeto

```
lib/
├── firestore/           # Configurações do Firestore
├── models/             # Modelos de dados
├── providers/          # Gerenciamento de estado
├── repositories/       # Camada de acesso a dados
├── screens/            # Telas do aplicativo
├── services/           # Serviços (autenticação, armazenamento)
├── theme/              # Temas e estilos
├── utils/              # Utilitários e helpers
└── widgets/            # Componentes reutilizáveis
```

## 🔧 Requisitos

- Flutter SDK (versão 3.6.0 ou superior)
- Dart SDK (versão 3.0.0 ou superior)
- Conta no Firebase
- Dispositivo móvel ou emulador configurado

## 🚀 Como Executar

1. **Clone o repositório**
   ```bash
   git clone [URL_DO_REPOSITORIO]
   cd Habitracker
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Configure o Firebase**
   - Crie um novo projeto no [Firebase Console](https://console.firebase.google.com/)
   - Adicione um aplicativo Android/iOS
   - Baixe os arquivos de configuração (`google-services.json` para Android e `GoogleService-Info.plist` para iOS)
   - Coloque-os nos locais apropriados:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Execute o aplicativo**
   ```bash
   flutter run
   ```

## 🔒 Configuração de Ambiente

### Variáveis de Ambiente
Crie um arquivo `.env` na raiz do projeto com as seguintes variáveis:

```
FIREBASE_API_KEY=sua_chave_aqui
FIREBASE_AUTH_DOMAIN=seu-projeto.firebaseapp.com
FIREBASE_PROJECT_ID=seu-projeto
FIREBASE_STORAGE_BUCKET=seu-projeto.appspot.com
FIREBASE_MESSAGING_SENDER_ID=seu_sender_id
FIREBASE_APP_ID=seu_app_id
```

## 🧪 Testes

Para executar os testes unitários:
```bash
flutter test
```

Para executar os testes de widget:
```bash
flutter test --platform=chrome
```

## 📦 Build e Deploy

### Android
```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

iOS
```bash
flutter build ios --release
```

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Faça commit das suas alterações (`git commit -m 'Add some AmazingFeature'`)
4. Faça push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## ✉️ Contato

Feito por Pedro Morato Lahoz - pedromoratolahoz@gmail.com

## 🐳 Executando com Docker

Para executar o projeto usando Docker, siga os passos abaixo:

1.  **Construa a imagem Docker**
    ```bash
    docker build -t habitracker-app .
    ```

2.  **Execute o contêiner Docker**
    ```bash
    docker run -p 5037:5037 -v "$(pwd)":/app habitracker-app
    ```

    Isso iniciará o aplicativo Flutter dentro de um contêiner Docker. O volume montado (`-v "$(pwd)":/app`) permite que as alterações no seu código local sejam refletidas dentro do contêiner.

    Se você estiver no Windows e usando PowerShell, o comando para montar o volume pode precisar ser ajustado para:
    ```bash
    docker run -p 5037:5037 -v "${PWD}":/app habitracker-app
    ```

    Ou, se estiver usando Git Bash/MinGW:
    ```bash
    docker run -p 5037:5037 -v "$(pwd)":/app habitracker-app
    ```

    O aplicativo será executado no modo de depuração e você poderá acessá-lo através do seu navegador ou emulador/dispositivo conectado, dependendo da configuração do Flutter. O comando `flutter run` dentro do Docker irá detectar automaticamente os dispositivos disponíveis.