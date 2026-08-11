# ServicTest — Banco de Dados na Nuvem (Supabase)

Este repositório contém o **ServicTest** (sistema de ensaios dielétricos e
elétricos, arquivo original `InnovaTest-Ensaios-Dieletricos.html`) adaptado
para ter login multiusuário e sincronizar na nuvem via **Supabase (Postgres)**,
seguindo a mesma lógica já usada no OrcaSystem e no GestãoCampo.

- `index.html` — o sistema completo.
- `supabase_schema.sql` — schema Postgres para colar no SQL Editor do Supabase.

## O que foi adicionado em relação ao arquivo original

O sistema original não tinha login nem sincronização — cada navegador guardava
seus próprios clientes e laudos, sem nenhum controle de quem via o quê. Foi
adicionado:

1. **Tela de login** (usuário/senha), com um Administrador inicial já
   cadastrado: login `vagner.r10`, senha `Vemsr8759` (troque depois de
   publicar, ou crie outro Administrador e remova este).
2. **Gestão de usuários** (em Configurações, só visível para Administrador):
   criar/editar nível (Administrador ou Usuário) e, para "Usuário", escolher
   quais **Clientes** ele pode ver.
3. **Restrição por cliente, só nos Laudos**: como pedido, a geração de
   qualquer ensaio continua 100% liberada para qualquer cliente cadastrado —
   a restrição vale apenas para a tela **Laudos Gerados** (e o Painel/Dashboard),
   que só mostra os laudos dos clientes liberados para aquele usuário.
   Administrador sempre vê tudo.
4. **Sincronização Supabase**: mesmo padrão dos outros dois sistemas — uma
   única tabela `app_state` guardando clientes, laudos, usuários e as
   configurações de cada tipo de ensaio, protegida por Row Level Security.

## Diferença técnica importante: IndexedDB

Diferente do OrcaSystem/GestãoCampo (que usam só `localStorage`), o ServicTest
guarda os **laudos** no **IndexedDB** do navegador, porque os laudos incluem
imagens de gráficos embutidas e podem passar do limite do `localStorage`
(5–10 MB). Isso não muda a lógica de sincronização — ao sincronizar, o array
de laudos inteiro é enviado/baixado do Supabase do mesmo jeito, só que a cópia
*local* de cada laudo fica no IndexedDB em vez do `localStorage`.

**Atenção ao crescer**: se o volume de laudos com gráficos ficar grande (várias
centenas, cada um com imagens), o payload de sincronização (um blob JSON só)
pode ficar pesado. Funciona bem na escala atual; se isso virar problema no
futuro, o próximo passo seria separar `laudos` numa tabela própria (uma linha
por laudo) em vez de dentro do blob único — mas isso é só necessário se/quando
o volume justificar.

## 1. Criar o projeto Supabase

1. Crie um novo projeto em https://supabase.com (recomendado um **projeto
   novo e separado**, para não misturar com OrcaSystem/GestãoCampo).
2. Abra **SQL Editor** → cole o conteúdo de `supabase_schema.sql` → **Run**.
3. Vá em **Settings → API** e copie a **Project URL** e a **anon public key**.
4. Abra o sistema publicado, faça login como `vagner.r10` / `Vemsr8759`, vá em
   **⚙️ Configurações → ☁️ Sincronização na Nuvem** e cole a URL e a anon key
   nos campos — clique em **Conectar e Sincronizar** (ele pede e-mail/senha do
   Supabase nessa primeira vez).
5. **Login unificado — sem tela extra**: depois de configurado, o login normal
   do sistema (usuário/senha cadastrados aqui) também autentica no Supabase por
   trás, usando um e-mail derivado: `usuario@servictest.local` (mesma senha
   local). Para cada pessoa que for usar o sistema em mais de um computador,
   crie a conta correspondente em **Authentication → Users → Add user**:
   - E-mail: `<usuario-local>@servictest.local` (tudo minúsculo)
   - Senha: **a mesma senha local dessa pessoa**
   - Marque "Auto Confirm User"
   Feito uma vez por pessoa, não por máquina.

## 2. Publicar o sistema (GitHub Pages)

1. Crie uma organização/repositório no GitHub sem o seu nome pessoal (ex.:
   organização `ServicTestPro`, mesmo padrão do OrcaSystemPro/GestaoCampoPro).
2. Suba os arquivos deste diretório (`index.html`, `supabase_schema.sql`, este
   `README.md`).
3. Em **Settings → Pages**, escolha "Deploy from a branch", branch `main`,
   pasta raiz (`/`). Em organização no plano gratuito, o repositório precisa
   ser **público** para o Pages funcionar.
4. Acesse pela URL publicada (não abra o `index.html` direto do disco).

## 3. Usar o sistema numa máquina nova

Não precisa configurar nada. Acesse a URL publicada e entre com o login local
normal (usuário/senha do sistema). Por trás, o sistema tenta autenticar essa
mesma pessoa no Supabase automaticamente:
- Se a conta na nuvem existir (passo 1.5) → baixa os dados reais (clientes,
  laudos, usuários) antes de validar o login local.
- Se não existir → segue funcionando só localmente, sem travar nada.

## Observações importantes

- A sincronização faz **pull antes de push**, e depois **mescla por id** (não
  substitui o array inteiro): cada laudo/cliente/usuário é comparado pelo seu
  `id` — a versão mais recente prevalece, mas nada criado localmente e ainda
  não sincronizado é apagado por um pull.
- Sincronização automática: qualquer criação/edição de cliente, laudo ou
  usuário agenda (2,5s de debounce) o envio para o Supabase — desde que a
  pessoa tenha conta na nuvem (passo 1.5).
- A `anon public key` fica visível no código-fonte da página publicada — isso
  é esperado e seguro *desde que* o Row Level Security do `supabase_schema.sql`
  esteja ativo (exige login para qualquer leitura/escrita). Nunca desative o RLS.
