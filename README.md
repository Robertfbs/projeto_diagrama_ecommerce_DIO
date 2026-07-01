# Projeto de Banco de Dados: E-commerce (Refinamento e Modelagem)

Este repositório contém a modelagem conceitual/física de um banco de dados para um sistema de e-commerce, desenvolvido originalmente como parte de um desafio de projeto da **Digital Innovation One (DIO)** e refinado para atender a requisitos acadêmicos específicos.

O projeto consiste no diagrama de Entidade-Relacionamento elaborado no **MySQL Workbench**, contendo o arquivo de modelagem original (`.mwb`) e uma exportação em imagem (`.png`).

---

## 📂 Arquivos no Repositório

*   [MER_e_commerce_DIO.mwb](MER_e_commerce_DIO.mwb): Arquivo fonte do modelo conceitual/físico para abertura e edição no MySQL Workbench.
*   [modelagem_ecommerce_DIO.png](modelagem_ecommerce_DIO.png): Imagem exportada do diagrama EER para visualização rápida.

---

## 🔍 Visão Geral do Modelo de Dados

O modelo de dados mapeia o fluxo operacional básico de um e-commerce marketplace, contemplando:
*   **Clientes:** Clientes finais que realizam compras.
*   **Produtos:** Itens comercializados na plataforma.
*   **Pedidos:** Registro das compras realizadas pelos clientes.
*   **Estoque:** Locais de armazenamento e quantidade disponível de cada produto.
*   **Fornecedores:** Parceiros de suprimento de produtos.
*   **Vendedores Terceiros (Marketplace):** Vendedores parceiros que utilizam a plataforma para comercializar seus próprios produtos.

---

## 🛠️ Refinamentos Solicitados & Soluções Propostas

Com base nas novas solicitações da orientadora para refino do modelo inicial criado em aula, abaixo estão as soluções estruturadas e documentadas:

### 1. Cliente PF e PJ — Exclusividade de Conta
> **Solicitação:** *"Uma conta de cliente pode ser PJ ou PF, mas não pode ter as duas informações associadas."*

*   **Solução Proposta (Abordagem Tabela Única - Single Table Inheritance):**
    *   Para garantir consistência e evitar `JOINs` complexos que prejudicariam a performance de consultas comuns, a melhor prática de mercado é consolidar os dados de Pessoa Física (CPF, data de nascimento) e Pessoa Jurídica (CNPJ, razão social, nome fantasia) diretamente na tabela principal `Cliente`.
    *   Um atributo discriminador `tipo_cliente` (definido como `ENUM('PF', 'PJ')` ou `VARCHAR`) identifica o tipo de conta.
    *   No banco de dados, é aplicada uma restrição `CHECK` para garantir a exclusividade mútua:
        ```sql
        CHECK (
            (tipo_cliente = 'PF' AND cpf IS NOT NULL AND cnpj IS NULL AND razao_social IS NULL AND nome_fantasia IS NULL) OR
            (tipo_cliente = 'PJ' AND cnpj IS NOT NULL AND cpf IS NULL AND data_nascimento IS NULL)
        )
        ```
    *   *Alternativa (Especialização Clássica):* Manter as tabelas filhas `Cliente_pf` e `Cliente_pj` conectadas via relacionamento `1:1` identificador com `Cliente`, utilizando chaves compostas contendo a coluna `tipo_cliente` para forçar a exclusividade por meio de chaves estrangeiras.

### 2. Pagamento — Múltiplas Formas de Pagamento
> **Solicitação:** *"Permitir que o cliente tenha cadastrado mais de uma forma de pagamento."*

*   **Solução Proposta (Normalização de Pagamentos):**
    *   Criação de uma nova entidade chamada `Forma_Pagamento` para atuar como a "carteira" do cliente. 
    *   Relacionamento `1:N` entre `Cliente` e `Forma_Pagamento` (um cliente pode cadastrar vários cartões de crédito, Pix, boleto, etc.).
    *   Para registrar o pagamento real do pedido, cria-se a tabela `Pagamento_Pedido` (ou `Transacao`), vinculando `Pedido` e `Forma_Pagamento`. Isso suporta cenários onde um único `Pedido` pode ser pago utilizando mais de um método (ex: dois cartões de crédito distintos ou saldo da carteira + boleto).

### 3. Entrega — Status e Rastreamento
> **Solicitação:** *"Adicionar informações de entrega contendo status e código de rastreio."*

*   **Solução Proposta (Tabela Dedicada `Entrega`):**
    *   Em e-commerces reais (especialmente marketplaces), um único pedido pode conter itens de diferentes vendedores, sendo enviado em pacotes distintos. Por isso, a melhor modelagem é criar uma tabela dedicada `Entrega`.
    *   A tabela `Entrega` possui chaves estrangeiras vinculadas a `Pedido` e armazena:
        *   `status_entrega` (ex: 'Em Processamento', 'Coletado', 'Enviado', 'Entregue').
        *   `codigo_rastreio` (para rastreamento com a transportadora/Correios).
        *   Datas logísticas: `data_envio`, `data_entrega_prevista` e `data_entrega_real`.

Este projeto demonstra a capacidade de traduzir requisitos de negócio (regras de e-commerce e restrições de integridade) em um modelo físico e conceitual robusto de banco de dados relacional.
