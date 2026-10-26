// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'TBT Center';

  @override
  String get tagline => 'GRUPO MULTINACIONAL';

  @override
  String gemPalette(String gem) {
    return 'Paleta $gem';
  }

  @override
  String get gemGold => 'Ouro';

  @override
  String get gemPlatinum => 'Platina';

  @override
  String get gemEmerald => 'Esmeralda';

  @override
  String get gemRuby => 'Rubi';

  @override
  String get gemSapphire => 'Safira';

  @override
  String get gemDiamond => 'Diamante';

  @override
  String get samplePayslipTitle => 'Holerite de outubro';

  @override
  String get viewDetails => 'Ver detalhes';

  @override
  String get downloadPdf => 'Baixar PDF';

  @override
  String get settings => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get languageAuto => 'Automático (pela localização)';

  @override
  String get dataRegion => 'Região dos dados';

  @override
  String get detecting => 'Detectando localização…';

  @override
  String get locationUnknown =>
      'Localização desconhecida, usando a região padrão';

  @override
  String detectedCountry(String country) {
    return 'País: $country';
  }

  @override
  String get refreshLocation => 'Detectar novamente';

  @override
  String get simulateLocation => 'Simular localização';

  @override
  String get simulateHint =>
      'Somente em builds de debug, para testar como se estivesse em outro país';

  @override
  String get simulateIp => 'Endereço IP';

  @override
  String get simulateCountry => 'Ou código do país (ex.: DE)';

  @override
  String get apply => 'Aplicar';

  @override
  String get clearSimulation => 'Remover simulação';

  @override
  String get regionVn => 'Vietnã';

  @override
  String get regionDe => 'Alemanha';

  @override
  String get regionUs => 'Estados Unidos';

  @override
  String get regionBr => 'Brasil';

  @override
  String get regionZa => 'África do Sul';

  @override
  String get regionAu => 'Austrália';

  @override
  String get bannerOffline =>
      'Sem conexão com a internet · exibindo dados salvos';

  @override
  String get bannerServerDown =>
      'Não foi possível acessar o servidor · exibindo dados salvos';

  @override
  String get bannerUnstable => 'Conexão instável';

  @override
  String get bannerRecovered => 'Conectado novamente';

  @override
  String get reconnect => 'Reconectar';

  @override
  String get errorNetwork =>
      'Sem conexão. Verifique o Wi-Fi ou os dados móveis.';

  @override
  String get errorTimeout =>
      'O servidor demorou demais para responder. Tente novamente.';

  @override
  String get errorServer =>
      'O servidor está com problemas. Tente novamente mais tarde.';

  @override
  String get errorUnauthorized => 'Sua sessão expirou. Entre novamente.';

  @override
  String get errorForbidden => 'Você não tem permissão para fazer isso.';

  @override
  String get errorNotFound => 'Os dados solicitados não foram encontrados.';

  @override
  String get errorValidation =>
      'Alguns dados são inválidos. Verifique e tente novamente.';

  @override
  String get errorOfflineWrite =>
      'É preciso conexão para salvar. O que você digitou foi mantido.';

  @override
  String get errorUnknown => 'Algo deu errado. Tente novamente.';

  @override
  String get signIn => 'Entrar';

  @override
  String get applyAsCandidate => 'Candidatar-se · criar conta';

  @override
  String get signOut => 'Sair';

  @override
  String welcome(String name) {
    return 'Olá, $name';
  }

  @override
  String dataStoredIn(String region) {
    return 'Seus dados ficam na região $region';
  }

  @override
  String get signInFailed =>
      'Não foi possível abrir a página de login. Verifique a conexão com o servidor.';

  @override
  String get roleExecutive => 'Diretoria';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get roleHr => 'Recursos humanos';

  @override
  String get roleFinance => 'Finanças';

  @override
  String get roleEmployee => 'Funcionário';

  @override
  String get roleCandidate => 'Candidato';

  @override
  String get regionCheckTitle => 'Conexão regional';

  @override
  String get regionCheckHint =>
      'Chama o servidor da sua região pelo Kong com o seu token.';

  @override
  String get regionCheckButton => 'Verificar';

  @override
  String regionCheckOk(String service) {
    return 'O servidor $service está respondendo';
  }

  @override
  String get savedDataNote => 'Exibindo dados salvos';

  @override
  String get themePreview => 'Ver paletas de pedras preciosas';

  @override
  String get employees => 'Fichas de funcionários';

  @override
  String get employeesHint => 'Lista e perfis de funcionários da sua região';

  @override
  String get open => 'Abrir';

  @override
  String get searchEmployees => 'Buscar por nome, ID ou e-mail';

  @override
  String employeeCount(int count) {
    return '$count funcionários';
  }

  @override
  String get noEmployees => 'Nenhum funcionário encontrado';

  @override
  String get loadMore => 'Carregar mais';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get sectionWork => 'Trabalho';

  @override
  String get sectionContact => 'Contato';

  @override
  String get sectionRelatives => 'Familiares';

  @override
  String get sectionHealth => 'Saúde';

  @override
  String get sectionInsurance => 'Seguro';

  @override
  String get fieldId => 'Matrícula';

  @override
  String get fieldCompany => 'Empresa';

  @override
  String get fieldDepartment => 'Departamento';

  @override
  String get fieldPosition => 'Cargo';

  @override
  String get fieldBirthYear => 'Ano de nascimento';

  @override
  String get fieldGender => 'Gênero';

  @override
  String get genderMale => 'Masculino';

  @override
  String get genderFemale => 'Feminino';

  @override
  String get fieldHiredOn => 'Data de admissão';

  @override
  String get fieldLaborContract => 'Contrato de trabalho';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldPhone => 'Telefone';

  @override
  String get fieldAddress => 'Endereço';

  @override
  String get fieldHometown => 'Naturalidade';

  @override
  String get fieldHeight => 'Altura';

  @override
  String get fieldWeight => 'Peso';

  @override
  String get fieldVision => 'Visão';

  @override
  String get fieldMedicalHistory => 'Histórico médico';

  @override
  String get fieldUpdatedOn => 'Atualizado';

  @override
  String get fieldInsuranceType => 'Tipo de seguro';

  @override
  String get fieldInsuranceNumber => 'Número do seguro';

  @override
  String get fieldExpiresOn => 'Validade';

  @override
  String get noData => 'Sem dados';

  @override
  String get attendance => 'Ponto e férias';

  @override
  String get attendanceHint => 'Suas horas, pedidos de férias e aprovações';

  @override
  String get tabTimesheet => 'Ponto';

  @override
  String get tabLeave => 'Férias';

  @override
  String get tabApprovals => 'Aprovações';

  @override
  String totalHours(String hours, int days) {
    return '$hours horas em $days dias';
  }

  @override
  String checkInOut(String checkIn, String checkOut) {
    return 'Entrada $checkIn · Saída $checkOut';
  }

  @override
  String overtimeHours(String hours) {
    return 'Hora extra $hours h';
  }

  @override
  String get newLeave => 'Pedir folga';

  @override
  String get leaveType => 'Tipo';

  @override
  String get leaveAnnual => 'Férias';

  @override
  String get leaveSick => 'Licença médica';

  @override
  String get leaveUnpaid => 'Licença não remunerada';

  @override
  String get leavePersonal => 'Assuntos pessoais';

  @override
  String get leaveDates => 'Período';

  @override
  String get pickDates => 'Escolher datas';

  @override
  String get reason => 'Motivo';

  @override
  String get submitLeave => 'Enviar';

  @override
  String get leaveSubmitted => 'Pedido enviado';

  @override
  String get statusPending => 'Pendente';

  @override
  String get statusApproved => 'Aprovado';

  @override
  String get statusRejected => 'Recusado';

  @override
  String get approve => 'Aprovar';

  @override
  String get reject => 'Recusar';

  @override
  String leaveDays(int days) {
    return '$days dias';
  }

  @override
  String get noLeaves => 'Nenhum pedido ainda';

  @override
  String get noPending => 'Nada aguardando aprovação';

  @override
  String get noTimesheets => 'Sem registros de ponto';

  @override
  String get leaveDecided => 'Pedido atualizado';

  @override
  String get errOverlap => 'Essas datas coincidem com outro pedido';

  @override
  String get errTooLong => 'Um pedido pode ter no máximo 30 dias';

  @override
  String get errInvalidDates => 'A data final deve ser após a inicial';

  @override
  String get errAlreadyDecided => 'Este pedido já foi tratado';

  @override
  String get errSelfApproval => 'Você não pode aprovar o próprio pedido';

  @override
  String get errRegionMismatch => 'Estes dados pertencem a outra região';

  @override
  String get errNoEmployee => 'Sua conta não está vinculada a um funcionário';

  @override
  String get myApplication => 'Minha candidatura';

  @override
  String get myApplicationHint => 'Candidate-se e acompanhe o andamento';

  @override
  String get candidates => 'Candidatos';

  @override
  String get candidatesHint => 'Candidaturas e etapas';

  @override
  String get applyNow => 'Candidatar-se';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get saveProfile => 'Salvar';

  @override
  String get fullName => 'Nome completo';

  @override
  String get appliedPosition => 'Vaga desejada';

  @override
  String get consentAi => 'Concordo que uma IA leia e resuma meu currículo';

  @override
  String get notAppliedYet => 'Você ainda não se candidatou';

  @override
  String get progress => 'Andamento';

  @override
  String get profileSaved => 'Perfil salvo';

  @override
  String get profileLockedHint =>
      'A candidatura já está na entrevista e não pode mais ser editada';

  @override
  String get moveTo => 'Mover para';

  @override
  String get statusChanged => 'Status atualizado';

  @override
  String get noCandidates => 'Nenhum candidato';

  @override
  String get allStatuses => 'Todos';

  @override
  String get note => 'Observação';

  @override
  String get stageSubmitted => 'Enviado';

  @override
  String get stageAnalyzed => 'Resumido pela IA';

  @override
  String get stageScreening => 'Triagem';

  @override
  String get stageInterview => 'Entrevista';

  @override
  String get stageOffered => 'Proposta';

  @override
  String get stageRejected => 'Não selecionado';

  @override
  String get errProfileLocked =>
      'A candidatura não pode mais ser editada nesta etapa';

  @override
  String get cvSection => 'Currículo';

  @override
  String get cvNone => 'Nenhum currículo';

  @override
  String get cvAttached => 'Currículo enviado';

  @override
  String get uploadCv => 'Enviar currículo (PDF)';

  @override
  String get replaceCv => 'Substituir currículo';

  @override
  String get cvUploaded => 'Currículo enviado';

  @override
  String get cvWaitingAi =>
      'A IA está lendo seu currículo, leva alguns minutos';

  @override
  String get openCv => 'Abrir currículo';

  @override
  String get aiSummary => 'Resumo da IA';

  @override
  String get aiDisclaimer =>
      'Gerado por IA. Confira com o currículo original antes de decidir.';

  @override
  String yearsExperience(String years) {
    return '$years anos de experiência';
  }

  @override
  String get skills => 'Habilidades';

  @override
  String get suitablePositions => 'Cargos adequados';

  @override
  String get strengths => 'Pontos fortes';

  @override
  String get interviewQuestions => 'Perguntar na entrevista';

  @override
  String get errCvNotPdf => 'O currículo deve ser um PDF';

  @override
  String get errCvTooLarge => 'O currículo pode ter no máximo 10 MB';

  @override
  String get payslips => 'Holerites';

  @override
  String get payslipsHint => 'Salário por período, bônus e descontos';

  @override
  String get baseSalary => 'Salário base';

  @override
  String get grossPay => 'Bruto';

  @override
  String get netPay => 'Líquido';

  @override
  String netUsd(String amount) {
    return '≈ $amount pela cotação do dia do pagamento';
  }

  @override
  String paidOn(String date) {
    return 'Pago em $date';
  }

  @override
  String get bonusesPenalties => 'Bônus / descontos';

  @override
  String get bonus => 'Bônus';

  @override
  String get penalty => 'Desconto';

  @override
  String get noPayslips => 'Nenhum holerite';

  @override
  String get payrollRuns => 'Fechamento da folha';

  @override
  String get payrollRunsHint => 'Calcular e pagar a região por período';

  @override
  String startPayrollRun(String period) {
    return 'Fechar folha de $period';
  }

  @override
  String get runRunning => 'Em andamento';

  @override
  String get runCompleted => 'Concluído';

  @override
  String get runFailed => 'Falhou, revertido';

  @override
  String get retryRun => 'Executar novamente';

  @override
  String get sagaSteps => 'Etapas';

  @override
  String get stepCollectHours => 'Coletar horas';

  @override
  String get stepFetchRate => 'Obter câmbio';

  @override
  String get stepCalculate => 'Calcular holerites';

  @override
  String get stepPay => 'Pagamento pelo canal de pagamento';

  @override
  String get stepComplete => 'Concluir';

  @override
  String get stepCompensate => 'Reverter parte não paga';

  @override
  String get stepRetry => 'Nova tentativa';

  @override
  String get stepResume => 'Retomado após reinício';

  @override
  String paidSummary(int count, String amount) {
    return '$count holerites pagos · $amount';
  }

  @override
  String get noRuns => 'Nenhum fechamento ainda';

  @override
  String get errRunExists => 'Este período já foi fechado';

  @override
  String get errRunFailed => 'Este período falhou, execute novamente';

  @override
  String get groupReport => 'Relatório do grupo';

  @override
  String get groupReportHint =>
      'Números consolidados de todas as regiões em USD';

  @override
  String get payrollCostByRegion => 'Custo da folha por região';

  @override
  String get leavesByRegion => 'Pedidos de folga por região';

  @override
  String get candidatesByRegion => 'Candidatos por região';

  @override
  String get groupTotal => 'Grupo inteiro';

  @override
  String dataAsOf(String id) {
    return 'Dados até o evento #$id';
  }

  @override
  String get noReportData => 'Sem dados ainda';

  @override
  String employeesCount(int count) {
    return '$count pessoas';
  }

  @override
  String get projects => 'Projetos e contratos';

  @override
  String get projectsHint => 'Projetos, clientes e equipe';

  @override
  String get searchProjects => 'Buscar projeto, contrato ou cliente';

  @override
  String get noProjects => 'Nenhum projeto';

  @override
  String get projectMoney => 'Valor do projeto';

  @override
  String get deposit => 'Sinal';

  @override
  String get expectedAcceptance => 'Aceite previsto';

  @override
  String get customer => 'Cliente';

  @override
  String get customerContactHidden =>
      'O contato do cliente é visível apenas para o financeiro';

  @override
  String get contracts => 'Contratos';

  @override
  String get projectMembers => 'Equipe';

  @override
  String get myProjects => 'Meus projetos';

  @override
  String get myProjectsHint => 'Projetos em que você trabalha e suas horas';

  @override
  String get noMyProjects => 'Você ainda não participa de projetos';

  @override
  String get finance => 'Finanças';

  @override
  String get financeHint =>
      'Receitas e custos mensais, fornecedores, fechamento';

  @override
  String get incomeExpense => 'Receitas e custos';

  @override
  String get suppliers => 'Fornecedores';

  @override
  String get revenue => 'Receita';

  @override
  String get cost => 'Custos';

  @override
  String get profit => 'Lucro';

  @override
  String get periodClosed => 'Fechado';

  @override
  String get closePeriod => 'Fechar mês';

  @override
  String get noFinanceData => 'Sem números para este ano';

  @override
  String get purchased => 'Comprado';

  @override
  String get paid => 'Pago';

  @override
  String get balance => 'Em aberto';

  @override
  String get recordPurchase => 'Registrar compra';

  @override
  String get recordPayment => 'Registrar pagamento';

  @override
  String get materialName => 'Material';

  @override
  String get amount => 'Valor';

  @override
  String get purchaseHistory => 'Compras';

  @override
  String get paymentHistory => 'Pagamentos';

  @override
  String get financeByRegion => 'Receitas e custos fechados';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get errPeriodClosed => 'Este mês está fechado';

  @override
  String get errPeriodNotEnded => 'Este mês ainda não terminou';

  @override
  String get errOverpaid => 'Pagamento maior que o valor em aberto';

  @override
  String get errInvalidAmount => 'Valor inválido';

  @override
  String closePeriodConfirm(String period) {
    return 'Fechar $period? Depois disso não será possível lançar neste mês.';
  }

  @override
  String hoursValue(String hours) {
    return '$hours h';
  }

  @override
  String get clockToday => 'Ponto de hoje';

  @override
  String get noShiftToday =>
      'Você não tem turno hoje, não é possível bater o ponto';

  @override
  String get clockIn => 'Registrar entrada';

  @override
  String get clockOut => 'Registrar saída';

  @override
  String get shiftDone => 'Turno concluído';

  @override
  String get holidayShift => 'Feriado';

  @override
  String get sundayShift => 'Domingo';

  @override
  String get tabOvertime => 'Horas extras';

  @override
  String get newOvertime => 'Solicitar horas extras';

  @override
  String get noOvertime => 'Nenhuma solicitação de horas extras';

  @override
  String get submitOvertime => 'Enviar';

  @override
  String get errNoShift => 'Você não tem turno hoje';

  @override
  String get errAlreadyClockedOut => 'Você já registrou a saída hoje';

  @override
  String get errTooSoon =>
      'Entrada recém-registrada, aguarde pelo menos 5 minutos';

  @override
  String get errInvalidHours => 'Horas extras devem estar entre 0,5 e 12';

  @override
  String clockedIn(String time) {
    return 'Entrada registrada às $time';
  }

  @override
  String clockedOut(String time, String hours) {
    return 'Saída às $time, $hours h trabalhadas';
  }

  @override
  String totalHoursToday(String hours) {
    return '$hours h trabalhadas hoje';
  }

  @override
  String get notifications => 'Notificações';

  @override
  String get noNotifications => 'Nenhuma notificação';

  @override
  String get markAllRead => 'Marcar como lidas';

  @override
  String get nGeneric => 'Você tem uma nova notificação';

  @override
  String nLeaveRequested(String employee, String days, String date) {
    return '$employee pediu $days dias de folga a partir de $date';
  }

  @override
  String nLeaveApproved(String date) {
    return 'Sua folga a partir de $date foi aprovada';
  }

  @override
  String nLeaveRejected(String date) {
    return 'Sua folga a partir de $date foi recusada';
  }

  @override
  String nOvertimeRequested(String employee, String hours, String date) {
    return '$employee pediu $hours h extras em $date';
  }

  @override
  String nOvertimeApproved(String date) {
    return 'Suas horas extras em $date foram aprovadas';
  }

  @override
  String nOvertimeRejected(String date) {
    return 'Suas horas extras em $date foram recusadas';
  }

  @override
  String nCandidateApplied(String position) {
    return 'Nova candidatura: $position';
  }

  @override
  String nCandidateStatus(String stage) {
    return 'Sua candidatura passou para: $stage';
  }

  @override
  String nPayrollPaid(String period) {
    return 'O salário de $period foi pago';
  }

  @override
  String nPayrollFailed(String period) {
    return 'A folha de $period falhou, execute novamente';
  }

  @override
  String nFinanceClosed(String period) {
    return 'As finanças de $period foram fechadas';
  }

  @override
  String get importCandidates => 'Importar candidatos de arquivo';

  @override
  String get confirmAll => 'Confirmar todos';

  @override
  String get importRowNew => 'Novo';

  @override
  String get importRowUpdate => 'Atualizar';

  @override
  String get importRowAccepted => 'Salvo';

  @override
  String get importErrMissingName => 'Nome ausente';

  @override
  String get importErrMissingContact => 'Sem e-mail e telefone';

  @override
  String get importErrInvalidEmail => 'E-mail inválido';

  @override
  String get errUnsupportedFile => 'Apenas arquivos .csv ou .xlsx';

  @override
  String get errMissingNameColumn => 'A primeira linha não tem coluna de nome';

  @override
  String get errEmptyFile => 'O arquivo não tem candidatos';

  @override
  String get errFileTooLarge => 'Arquivo maior que 2 MB';

  @override
  String confirmSelected(int count) {
    return 'Confirmar selecionados ($count)';
  }

  @override
  String importAccepted(int count) {
    return '$count perfis salvos';
  }

  @override
  String importSummary(int total, int pending) {
    return '$total linhas, $pending aguardando confirmação';
  }

  @override
  String importRowNumber(int n) {
    return 'Linha $n';
  }

  @override
  String get roleAuditor => 'Auditor';

  @override
  String get gemAmethyst => 'Ametista';

  @override
  String get auditLog => 'Registro de auditoria';

  @override
  String get auditLogHint =>
      'Eventos de todas as regiões, verificação da cadeia, exportação';

  @override
  String get auditEvents => 'Eventos';

  @override
  String get accessLog => 'Registro de acesso';

  @override
  String get verifyChain => 'Verificar cadeia';

  @override
  String get exportAudit => 'Exportar para auditoria';

  @override
  String get auditSearch => 'Consulta';

  @override
  String get chainIntact => 'O registro está íntegro';

  @override
  String get exportChecksumHint =>
      'SHA-256 do arquivo exportado. Se o valor recalculado for diferente, o arquivo foi alterado.';

  @override
  String get copyChecksum => 'Copiar';

  @override
  String get close => 'Fechar';

  @override
  String get allRegions => 'Todas as regiões';

  @override
  String get errAccessExpired => 'Seu acesso de auditoria expirou';

  @override
  String chainBroken(String id) {
    return 'Cadeia quebrada na linha #$id';
  }

  @override
  String chainChecked(int count) {
    return '$count linhas verificadas';
  }

  @override
  String exportDone(int count) {
    return '$count linhas exportadas';
  }

  @override
  String rowsCount(int count) {
    return '$count linhas';
  }

  @override
  String supplierPurchases(int count) {
    return '$count compras';
  }

  @override
  String supplierPaidPercent(String percent) {
    return '$percent% pago';
  }

  @override
  String get acceptProject => 'Aceitar projeto';

  @override
  String get projectInProgress => 'Em andamento';

  @override
  String get errAlreadyAccepted => 'Este projeto já foi aceito';

  @override
  String get errFinanceUnavailable =>
      'O financeiro não registrou a receita; o projeto não foi alterado.';

  @override
  String acceptProjectConfirm(String amount) {
    return 'Aceitar o projeto e registrar $amount como receita?';
  }

  @override
  String projectAcceptedOn(String date) {
    return 'Aceito em $date';
  }

  @override
  String nProjectAccepted(String project) {
    return 'Projeto $project aceito, receita registrada';
  }

  @override
  String get workConditions => 'Condições de trabalho';

  @override
  String workHoursSummary(String hours, String overtime) {
    return '$hours h · extras $overtime h';
  }

  @override
  String get noticeQueued => 'na fila';

  @override
  String get noticeSent => 'enviado';

  @override
  String customerNotice(String channel, String status) {
    return 'Confirmação ao cliente por $channel: $status';
  }

  @override
  String get attachCv => 'Anexar currículo (PDF, até 10 MB)';

  @override
  String cvSelected(String name) {
    return 'Currículo: $name';
  }

  @override
  String get stageHired => 'Contratado';

  @override
  String get hireCandidate => 'Contratar';

  @override
  String get hiredKeepPassword => 'Senha: a mesma que a pessoa já usa.';

  @override
  String get hiredRelogin =>
      'A pessoa deve sair e entrar de novo para receber o papel de Funcionário.';

  @override
  String hireConfirm(String name, String email) {
    return 'Contratar $name? $email será o login do novo funcionário.';
  }

  @override
  String hiredTitle(String id) {
    return 'Funcionário $id criado';
  }

  @override
  String hiredLogin(String login) {
    return 'Login: $login';
  }

  @override
  String hiredTempPassword(String password) {
    return 'Senha temporária: $password (exibida uma vez, troque no primeiro acesso)';
  }

  @override
  String get home => 'Início';

  @override
  String get sectionMyWork => 'Meu trabalho';

  @override
  String get sectionManage => 'Gestão';

  @override
  String get sectionFinance => 'Finanças';

  @override
  String get sectionAudit => 'Auditoria';

  @override
  String nPayslipIssued(String period) {
    return 'Seu holerite de $period está disponível';
  }

  @override
  String nPayrollNeedsAttention(String period) {
    return 'A folha de $period precisa de tratamento manual';
  }

  @override
  String get errPeriodLocked =>
      'A folha deste período está sendo fechada. Tente novamente em alguns minutos';

  @override
  String get runNeedsAttention => 'Requer atenção';

  @override
  String get stepLockPeriod => 'Bloquear período no ponto';

  @override
  String get stepReserveBudget => 'Reservar orçamento da folha';

  @override
  String get stepReleaseBudget => 'Liberar orçamento (compensação)';

  @override
  String get stepRecordExpense => 'Registrar despesa da folha no financeiro';

  @override
  String get stepIssuePayslips => 'Enviar holerites aos funcionários';

  @override
  String get stepUnlockPeriod => 'Desbloquear período';

  @override
  String get stepNeedsAttention => 'Aguardando tratamento manual';

  @override
  String get knowledge => 'Base de conhecimento';

  @override
  String get knowledgeHint =>
      'Regras de salário, férias, horas extras e processos';

  @override
  String get knowledgeSearchHint => 'Buscar, ex.: horas extras, folha';

  @override
  String get knowledgeEmpty => 'Nenhum artigo encontrado';

  @override
  String get sectionKnowledge => 'Conhecimento';

  @override
  String get knowledgeTabAsk => 'Perguntar à IA';

  @override
  String get knowledgeTabSearch => 'Artigos';

  @override
  String get knowledgeTabGraph => 'Grafo';

  @override
  String get askHint => 'Pergunte sobre salário, férias, ponto…';

  @override
  String get askIntro =>
      'O assistente responde com base na base de conhecimento e no grafo da empresa, com fontes para conferir.';

  @override
  String get askExample1 => 'Como as horas extras são pagas?';

  @override
  String get askExample2 => 'Quem aprova meu pedido de férias?';

  @override
  String get askExample3 =>
      'Por que não consigo aprovar pedidos durante o fechamento da folha?';

  @override
  String get askExample4 => 'Como meus dados pessoais são protegidos?';

  @override
  String get askThinking => 'Pesquisando a base de conhecimento…';

  @override
  String get askSources => 'Fontes';

  @override
  String get askGraphFacts => 'Do grafo de conhecimento';

  @override
  String askAnsweredBy(String model) {
    return 'Respondido por $model';
  }

  @override
  String get askNoAi => 'Sem IA, citado da base de conhecimento';

  @override
  String get askCached => 'em cache';

  @override
  String get askHelpful => 'Útil';

  @override
  String get askNotHelpful => 'Não ajudou';

  @override
  String get askThanks => 'Obrigado pelo retorno';

  @override
  String get askFailed => 'Não foi possível enviar a pergunta';

  @override
  String get askNewChat => 'Nova conversa';

  @override
  String get askSend => 'Enviar';

  @override
  String get askViaKeyword => 'palavra-chave';

  @override
  String get askViaSemantic => 'significado';

  @override
  String get askViaGraph => 'grafo';

  @override
  String get graphSearchHint => 'Buscar conceito, ex.: horas extras';

  @override
  String get graphRelated => 'Conexões';

  @override
  String get graphReadArticle => 'Ler artigo';

  @override
  String get graphAskAbout => 'Perguntar à IA sobre isto';

  @override
  String graphAskTemplate(String topic) {
    return 'Explique $topic para mim';
  }

  @override
  String get graphTypeConcept => 'Conceito';

  @override
  String get graphTypeProcess => 'Processo';

  @override
  String get graphTypeStep => 'Etapa';

  @override
  String get graphTypeRule => 'Regra';

  @override
  String get graphTypeRole => 'Papel';

  @override
  String get graphTypeService => 'Serviço';

  @override
  String get graphTypeRegion => 'País';

  @override
  String get graphTypeDocument => 'Artigo';

  @override
  String get knowledgeMore => 'Mais';

  @override
  String get ontologyTitle => 'Ontologia';

  @override
  String get ontologyClasses => 'Árvore de classes';

  @override
  String get ontologyRelations => 'Relações';

  @override
  String get ontologyRules => 'Regras de inferência';

  @override
  String ontologyTotals(int nodes, int asserted, int extracted, int inferred) {
    return '$nodes nós · $asserted arestas definidas · $extracted extraídas por IA · $inferred inferidas';
  }

  @override
  String ontologyReasoning(int count, int ms) {
    return 'Último raciocínio: $count novas arestas em $ms ms';
  }

  @override
  String get ontologyRerun => 'Executar raciocínio';

  @override
  String get ontologyTransitive => 'transitiva';

  @override
  String get ontologySymmetric => 'simétrica';

  @override
  String ontologyInverse(String name) {
    return 'inversa de $name';
  }

  @override
  String ontologySubProperty(String name) {
    return 'implica $name';
  }

  @override
  String get ontologyDerived => 'só inferida';

  @override
  String ontologyEdgeCount(int count) {
    return '$count arestas';
  }

  @override
  String get ontologyExport =>
      'Exportação RDF/OWL (Turtle) em /knowledge/ontology?format=turtle, abre no Protégé.';

  @override
  String get sparqlTitle => 'Consulta SPARQL';

  @override
  String get sparqlHint => 'Escreva um SELECT ou escolha um exemplo';

  @override
  String get sparqlRun => 'Executar';

  @override
  String get sparqlIncludeInferred => 'Incluir arestas inferidas';

  @override
  String get sparqlNoRows => 'Sem resultados';

  @override
  String sparqlRows(int count, int ms) {
    return '$count linhas · $ms ms';
  }

  @override
  String sparqlError(String message) {
    return 'Erro na consulta: $message';
  }

  @override
  String get sparqlSampleInvolves => 'Serviços do fechamento da folha';

  @override
  String get sparqlSampleViewers => 'Quem vê o salário líquido';

  @override
  String get sparqlSampleBefore => 'Etapas antes do pagamento';

  @override
  String get sparqlSampleRabbit => 'Serviços que usam RabbitMQ';

  @override
  String get sparqlSampleCount => 'Serviços por local';

  @override
  String get proposalsTitle => 'Propostas da IA';

  @override
  String get proposalsRun => 'IA ler artigos novos';

  @override
  String get proposalsRunning => 'A IA está lendo…';

  @override
  String proposalsQueued(int count) {
    return 'A IA vai ler $count artigos';
  }

  @override
  String get proposalsNoAi => 'Nenhuma IA configurada para extração';

  @override
  String get proposalsPending => 'Pendentes';

  @override
  String get proposalsInvalid => 'Inválidas';

  @override
  String get proposalsApproved => 'Aprovadas';

  @override
  String get proposalsRejected => 'Rejeitadas';

  @override
  String get proposalsEmpty => 'Sem propostas';

  @override
  String get proposalNewNode => 'Novo nó';

  @override
  String proposalFrom(String article) {
    return 'Citado de $article';
  }

  @override
  String get proposalApprove => 'Aprovar';

  @override
  String get proposalReject => 'Rejeitar';

  @override
  String get proposalApproved => 'Adicionado ao grafo, raciocinando de novo';

  @override
  String get proposalRejected => 'Proposta rejeitada';

  @override
  String proposalConfidence(int percent) {
    return 'Confiança $percent%';
  }

  @override
  String get proposalReasonEvidence => 'A citação não está no artigo';

  @override
  String get proposalReasonConfidence => 'A IA não tem certeza';

  @override
  String proposalReasonOntology(String code) {
    return 'Viola domínio ou alcance ($code)';
  }

  @override
  String get proposalReasonUnused => 'Nó não usado por nenhuma aresta válida';

  @override
  String proposalReasonOther(String code) {
    return 'Motivo: $code';
  }

  @override
  String get graphInferred => 'Inferida';

  @override
  String graphInferredBy(String rule) {
    return 'Inferida pela regra: $rule';
  }

  @override
  String get graphBecause => 'Porque';

  @override
  String get graphEvidence =>
      'Extraída pela IA de um artigo, aprovada pelo RH:';

  @override
  String get graphGoTo => 'Abrir este nó';

  @override
  String get graphPathTo => 'Ligar a…';

  @override
  String graphPathTitle(String from, String to) {
    return 'De $from até $to';
  }

  @override
  String get graphPathNone => 'Sem ligação em 6 passos';

  @override
  String get graphPathPick => 'Escolha o conceito de destino';

  @override
  String get graphTypeTechnology => 'Tecnologia';

  @override
  String get graphTypePattern => 'Padrão de arquitetura';

  @override
  String get todoTitle => 'Pendências';

  @override
  String todoLeaves(int count) {
    return '$count pedidos de folga aguardando aprovação';
  }

  @override
  String todoOvertime(int count) {
    return '$count pedidos de hora extra aguardando aprovação';
  }

  @override
  String todoCandidates(int count) {
    return '$count novas candidaturas';
  }

  @override
  String get todoNone => 'Nada aguardando você';

  @override
  String get signOutConfirm => 'Sair do TBT Center?';

  @override
  String get stepErrorTimeout =>
      'O canal de pagamento não respondeu a tempo; o sistema concilia pela referência antes de pagar de novo';

  @override
  String get stepErrorGeneric =>
      'Esta etapa não pôde ser executada; toque em Tentar novamente ou fale com a TI';

  @override
  String get errSparqlSyntax =>
      'A consulta tem um erro de sintaxe. Verifique os parênteses, o ponto após cada padrão e os prefixos (kg:, kgo:).';

  @override
  String get appearance => 'Aparência';

  @override
  String get themeSystem => 'Igual ao telefone';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get payoutCompany => 'Empresa';

  @override
  String payoutPayRegion(String region) {
    return 'Pagar $region';
  }

  @override
  String get payoutPayGroup => 'Pagar todo o grupo';

  @override
  String payoutPaySelected(int count) {
    return 'Pagar $count pessoas';
  }

  @override
  String payoutConfirmTitle(String period) {
    return 'Pagar o período $period?';
  }

  @override
  String payoutConfirmRegion(String region) {
    return 'Paga os funcionários de $region. Quem já recebeu aparece antes para você decidir.';
  }

  @override
  String payoutConfirmGroup(int count) {
    return 'Paga os funcionários das $count empresas. Quem já recebeu aparece antes para você decidir.';
  }

  @override
  String payoutConfirmPeople(int count, String region) {
    return 'Paga as $count pessoas selecionadas em $region.';
  }

  @override
  String get payoutConfirm => 'Pagar';

  @override
  String get payoutDuplicateTitle => 'Algumas pessoas já receberam';

  @override
  String get payoutDuplicateBody =>
      'Pagar de novo envia o salário mais uma vez. Qualquer escolha fica no registro.';

  @override
  String payoutDuplicateRegion(String region, int count) {
    return '$region: $count já pagos';
  }

  @override
  String payoutDuplicatePerson(String employee, int count) {
    return '$employee · pago $count vezes';
  }

  @override
  String get payoutSkipPaid => 'Pular quem já recebeu';

  @override
  String get payoutResend => 'Pagar de novo';

  @override
  String get payoutTabPeople => 'Funcionários';

  @override
  String get payoutTabRuns => 'Execuções';

  @override
  String get payoutTabLog => 'Registro';

  @override
  String get payoutUnpaid => 'Não pago';

  @override
  String payoutPaidTimes(int count) {
    return 'Pago $count vezes';
  }

  @override
  String get payoutNotCalculated =>
      'Este período ainda não foi processado. Pague a empresa inteira primeiro.';

  @override
  String get payoutResultTitle => 'Resultado do pagamento';

  @override
  String payoutResultSummary(int paid, int resent, int skipped) {
    return 'Pagos $paid · de novo $resent · pulados $skipped';
  }

  @override
  String payoutResultFailed(int count) {
    return '$count pagamentos não concluídos, tente mais tarde';
  }

  @override
  String payoutResultMissing(int count) {
    return '$count pessoas sem contracheque neste período';
  }

  @override
  String get payoutStarted => 'Folha iniciada, pagando';

  @override
  String get payoutRetried => 'Pagando a parte restante';

  @override
  String get payoutBusy =>
      'Este período está em processamento, tente de novo quando terminar';

  @override
  String get payoutUnreachable =>
      'Não foi possível acessar o servidor desta empresa';

  @override
  String get payoutNothing => 'Nada a pagar';

  @override
  String get payoutAmountHidden => 'Valores visíveis só dentro dessa empresa';

  @override
  String get payoutLogPaid => 'Pago';

  @override
  String get payoutLogResent => 'Pago de novo';

  @override
  String get payoutLogSkipped => 'Pulado, já pago';

  @override
  String get payoutLogWarned => 'Aviso de pagamento duplicado';

  @override
  String get payoutLogFailed => 'Não concluído';

  @override
  String get payoutLogSaga => 'Folha automática';

  @override
  String payoutLogLine(String actor, String time) {
    return '$actor · $time';
  }

  @override
  String get noPayoutLog => 'Nenhum pagamento ainda';

  @override
  String get errPayoutFailed =>
      'O pagamento foi interrompido. Os pagamentos feitos foram registrados, tente mais tarde.';

  @override
  String payoutAccepted(int count) {
    return 'Pagando $count itens, acompanhe na aba Registro';
  }

  @override
  String get payoutLogInDoubt => 'Incerto, precisa conciliar';

  @override
  String get manualIpButton => 'Change Manual IP';

  @override
  String get manualIpTitle => 'IP manual';

  @override
  String get manualIpHint =>
      'Digite um IP público para simular estar nesse país: região e idioma são detectados por ele. Deixe vazio para usar o IP real.';

  @override
  String manualIpCurrent(String region) {
    return 'Região detectada: $region';
  }

  @override
  String get manualIpInvalid => 'IP inválido';

  @override
  String manualIpSaved(String ip) {
    return 'Simulando o IP $ip';
  }

  @override
  String get manualIpCleared => 'Usando o IP real de novo';

  @override
  String get manualIpReset => 'IP real';

  @override
  String moreNotifications(int count) {
    return 'e mais $count';
  }

  @override
  String get filterAll => 'Todos';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterType => 'Tipo';

  @override
  String get filterRead => 'Lidas';

  @override
  String get filterUnread => 'Não lidas';

  @override
  String get profileTab => 'Perfil';

  @override
  String get myProfile => 'Meu perfil';

  @override
  String get proposeChange => 'Solicitar alteração';

  @override
  String get proposeChangeHint =>
      'Edite só o que mudou. O perfil é atualizado após aprovação do RH.';

  @override
  String get changeReason => 'Motivo (opcional)';

  @override
  String get sendRequest => 'Enviar solicitação';

  @override
  String get changeRequestSent => 'Solicitação enviada, aguardando o RH';

  @override
  String get changeRequestPending => 'Há uma solicitação aguardando o RH';

  @override
  String get changeRequestNoChange => 'Nada foi alterado';

  @override
  String get changeHistory => 'Histórico de solicitações';

  @override
  String get changeRequests => 'Alterações de perfil';

  @override
  String get changeRequestsHint => 'Funcionários pedindo para atualizar dados';

  @override
  String pendingChangeRequests(int count) {
    return '$count alterações de perfil';
  }

  @override
  String get noChangeRequests => 'Nenhuma solicitação';

  @override
  String get oldValue => 'Antigo';

  @override
  String get newValue => 'Novo';

  @override
  String get decisionNote => 'Observação (opcional)';

  @override
  String get fieldFacebook => 'Facebook';

  @override
  String get fieldXHandle => 'Conta X';

  @override
  String get accountInfo => 'Conta';

  @override
  String nProfileChangeRequested(String employee) {
    return '$employee pediu para atualizar o perfil';
  }

  @override
  String get nProfileChangeApproved => 'O RH aprovou suas alterações';

  @override
  String nProfileChangeRejected(String note) {
    return 'O RH rejeitou suas alterações: $note';
  }

  @override
  String get invalidAmount => 'Valor inválido';

  @override
  String get invalidEmail => 'E-mail inválido';

  @override
  String todoProfileChanges(int count) {
    return '$count alterações de perfil';
  }

  @override
  String get departments => 'Departamentos';

  @override
  String get departmentsHint => 'Transferências, chefias, dissolução';

  @override
  String get departmentAdd => 'Adicionar departamento';

  @override
  String get departmentName => 'Nome do departamento';

  @override
  String get departmentNameTaken =>
      'Esta empresa já tem um departamento com esse nome';

  @override
  String departmentCreated(String name) {
    return 'Departamento $name adicionado';
  }

  @override
  String get departmentEmpty => 'Ainda não há ninguém neste departamento';

  @override
  String get departmentHead => 'Chefe';

  @override
  String departmentHeadIs(String name) {
    return 'Chefe: $name';
  }

  @override
  String departmentMembers(int count) {
    return '$count pessoas';
  }

  @override
  String get noHead => 'Sem chefe';

  @override
  String get noDepartments => 'Nenhum departamento ainda';

  @override
  String get sortedByHours => 'Chefe primeiro, depois por total de horas';

  @override
  String get setHead => 'Tornar chefe';

  @override
  String headAssigned(String name) {
    return '$name agora é o chefe';
  }

  @override
  String get moveToDepartment => 'Transferir para outro departamento';

  @override
  String get moveHere => 'Transferir para cá';

  @override
  String transferDone(String name) {
    return 'Transferido para $name';
  }

  @override
  String get addMembers => 'Adicionar pessoas';

  @override
  String get addMembersFrom => 'De qual departamento?';

  @override
  String addMembersTitle(String name) {
    return 'Transferir para $name';
  }

  @override
  String membersMoved(int count) {
    return '$count pessoas transferidas';
  }

  @override
  String membersMovedPartly(int moved, int failed) {
    return '$moved transferidas, $failed não puderam ser';
  }

  @override
  String get dissolveDepartment => 'Dissolver departamento';

  @override
  String dissolveTitle(String name) {
    return 'Dissolver $name?';
  }

  @override
  String get dissolveReason => 'Motivo';

  @override
  String get dissolveNoLongerNeeded => 'Não é mais necessário';

  @override
  String get dissolveRestructured => 'Reestruturado ou fundido';

  @override
  String get dissolveUnderperforming => 'Baixo desempenho';

  @override
  String get dissolveOutsourced => 'Terceirizado';

  @override
  String get dissolveBusinessClosed => 'Área de negócio reduzida ou encerrada';

  @override
  String dissolveMembersMove(int count) {
    return 'Restam $count pessoas; escolha o departamento que as recebe';
  }

  @override
  String get chooseReceivingDepartment => 'Escolher departamento';

  @override
  String get dissolveConfirm => 'Dissolver';

  @override
  String dissolveDone(String name) {
    return '$name dissolvido';
  }

  @override
  String get unassignedStaff => 'Novos sem departamento';

  @override
  String unassignedCount(int count) {
    return '$count novos sem departamento';
  }

  @override
  String get unassignedHint => 'A IA sugere um departamento ou um novo';

  @override
  String get noUnassigned => 'Todos têm departamento';

  @override
  String get aiSuggestPlacement => 'Sugestões da IA';

  @override
  String get aiThinking => 'A IA está analisando...';

  @override
  String get suggestionByAi => 'Sugerido pela IA; o RH decide';

  @override
  String get suggestionByRules =>
      'IA indisponível; sugestão por cargos semelhantes';

  @override
  String suggestedDepartment(String name) {
    return 'Sugestão: $name';
  }

  @override
  String get acceptSuggestion => 'Aceitar';

  @override
  String get chooseOther => 'Escolher outro';

  @override
  String get chooseDepartment => 'Escolher departamento';

  @override
  String get newDepartmentProposals => 'Novos departamentos propostos';

  @override
  String get createDepartmentAndMove => 'Criar e transferir';

  @override
  String get rankings => 'Destaques';

  @override
  String get rankingsHint => 'Ranking por horas, indicações';

  @override
  String get rankingFormula =>
      'Pontos = horas normais + 1,5 × horas extras + 2 × dias trabalhados';

  @override
  String rankingDetail(String work, String overtime, int days) {
    return '$work h · $overtime h extras · $days dias';
  }

  @override
  String get points => 'pontos';

  @override
  String get noRankings => 'Sem dados de ponto neste período';

  @override
  String lastMonths(int count) {
    return 'Últimos $count meses';
  }

  @override
  String get filterPeriod => 'Período';

  @override
  String get filterDepartment => 'Departamento';

  @override
  String get filterPosition => 'Cargo';

  @override
  String get filterCompany => 'Empresa';

  @override
  String get filterRegion => 'Região';

  @override
  String get statusWorking => 'Ativo';

  @override
  String get statusArchived => 'Arquivado';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get nominatePromotion => 'Indicar para promoção';

  @override
  String nominateTitle(String name) {
    return 'Indicar $name';
  }

  @override
  String get proposedPosition => 'Cargo proposto';

  @override
  String get raisePercent => 'Aumento salarial';

  @override
  String get raisePercentInvalid => 'Informe de 0,1 a 100';

  @override
  String get nominationReason => 'Motivo da indicação';

  @override
  String get sendToExecutives => 'Enviar à diretoria';

  @override
  String get nominationSent => 'Indicação enviada à diretoria';

  @override
  String get nominations => 'Indicações de promoção';

  @override
  String get nominationsHint => 'A diretoria aprova cargo e salário';

  @override
  String get noNominations => 'Nenhuma indicação';

  @override
  String raiseBy(String percent) {
    return 'Aumento de $percent%';
  }

  @override
  String get approvePromotion => 'Aprovar promoção';

  @override
  String approvePromotionHint(String name, String position, String percent) {
    return '$name passa a $position com aumento de $percent% no salário-base.';
  }

  @override
  String get promotionApproved => 'Aprovado: cargo e salário atualizados';

  @override
  String get promotionApprovedNoRaise => 'Cargo alterado; aumento pendente';

  @override
  String get promotionRejected => 'Indicação recusada';

  @override
  String todoNominations(int count) {
    return '$count promoções para avaliar';
  }

  @override
  String get archiveProfile => 'Arquivar perfil';

  @override
  String archiveTitle(String name) {
    return 'Arquivar $name?';
  }

  @override
  String archiveProjectsWarning(int count) {
    return 'Esta pessoa está em $count projetos e será removida de todos:';
  }

  @override
  String get archiveNoProjects => 'Esta pessoa não está em nenhum projeto.';

  @override
  String get archiveKeepsPersonal =>
      'Os dados pessoais são mantidos e o perfil pode ser restaurado.';

  @override
  String get archiveReason => 'Motivo';

  @override
  String get archiveConfirm => 'Arquivar';

  @override
  String archiveDone(int count) {
    return 'Arquivado e removido de $count projetos';
  }

  @override
  String profileArchivedBanner(String reason) {
    return 'Perfil arquivado. Motivo: $reason';
  }

  @override
  String get restoreProfile => 'Restaurar';

  @override
  String get restoreDone => 'Perfil restaurado';

  @override
  String get fieldRequired => 'Obrigatório';

  @override
  String get errIsHead => 'Defina outro chefe antes de transferir';

  @override
  String get errLastMember => 'O departamento precisa de pelo menos uma pessoa';

  @override
  String get errSameDepartment => 'Já está neste departamento';

  @override
  String get errArchived => 'Perfil arquivado; restaure primeiro';

  @override
  String get errNotArchived => 'Este perfil não está arquivado';

  @override
  String get errMembersRemaining => 'Ainda há pessoas; escolha um departamento';

  @override
  String get errNotMember => 'Não pertence a este departamento';

  @override
  String get errPendingExists => 'Já existe um pedido aguardando';

  @override
  String get errServiceUnavailable =>
      'Parte do sistema está ocupada; tente em instantes';

  @override
  String nPromotionNominated(String employee, String position) {
    return '$employee indicado para $position';
  }

  @override
  String nPromotionApproved(String position) {
    return 'Parabéns! Você foi promovido a $position';
  }

  @override
  String nPromotionRejected(String position) {
    return 'Promoção a $position não aprovada';
  }

  @override
  String nPromotionApprovedHr(String employee) {
    return 'Promoção de $employee aprovada';
  }

  @override
  String nPromotionRejectedHr(String employee) {
    return 'Promoção de $employee recusada';
  }

  @override
  String get nEmployeeTransferred =>
      'Você foi transferido para um novo departamento';

  @override
  String get nDepartmentHeadAssigned => 'Agora você chefia o seu departamento';

  @override
  String memberHours(String hours) {
    return '$hours h';
  }

  @override
  String get stageInterviewed => 'Entrevistado';

  @override
  String get interviewAwaitingCandidate => 'Aguardando candidato';

  @override
  String get interviewAwaitingHr => 'Aguardando RH';

  @override
  String get interviewConfirmed => 'Confirmada';

  @override
  String get interviewCancelled => 'Cancelada';

  @override
  String get interviewSchedule => 'Entrevista';

  @override
  String minutesAttached(String name) {
    return 'Ata: $name';
  }

  @override
  String get chooseInterviewTime => 'Escolher data e hora';

  @override
  String get errTimeInPast => 'O horário deve ser no futuro';

  @override
  String get interviewLocation => 'Local ou link da reunião';

  @override
  String get send => 'Enviar';

  @override
  String get rejectCandidate => 'Recusar';

  @override
  String rejectCandidateHint(String name) {
    return 'Recusar $name? É possível reconsiderar depois.';
  }

  @override
  String get scheduleInterview => 'Agendar entrevista';

  @override
  String get scheduleAgain => 'Reagendar';

  @override
  String get interviewSent => 'Horário enviado, aguardando confirmação';

  @override
  String get proposeOtherTime => 'Sugerir outro horário';

  @override
  String get confirmTime => 'Confirmar horário';

  @override
  String get interviewConfirmedDone => 'Entrevista confirmada';

  @override
  String get uploadMinutes => 'Enviar ata da entrevista';

  @override
  String get minutesUploaded => 'Ata salva, candidato entrevistado';

  @override
  String get minutesAfterInterview =>
      'Envie a ata (Word, Excel) depois da entrevista';

  @override
  String get openMinutes => 'Abrir ata';

  @override
  String get moveToScreening => 'Mover para triagem';

  @override
  String get reconsider => 'Reconsiderar';

  @override
  String get reconsidered => 'Candidatura voltou à etapa anterior';

  @override
  String get waitingCandidateReply =>
      'Aguardando o candidato confirmar ou sugerir horário';

  @override
  String get waitingHrReply => 'Aguardando o RH confirmar seu horário';

  @override
  String get hiredSalaryPending =>
      'Salário não salvo, informe novamente em Folha';

  @override
  String get offerFromAi => 'Sugestão da IA';

  @override
  String get offerFromRules => 'Sugestão pelos dados';

  @override
  String get offerPeerMedian =>
      'Salário mediano do mesmo cargo, departamento com mais colegas';

  @override
  String get offerRegionMedian =>
      'Sem colegas: mediana regional, maior departamento';

  @override
  String get agreedSalary => 'Salário base acordado';

  @override
  String get currency => 'Moeda';

  @override
  String get errInvalidStep =>
      'Etapa não permitida agora, atualize para ver a etapa atual';

  @override
  String get errNotScreened => 'Faça a triagem antes de agendar';

  @override
  String get errInterviewNotConfirmed =>
      'A entrevista ainda não foi confirmada';

  @override
  String get errNotInterviewed => 'Envie a ata antes de contratar';

  @override
  String get errNotRejected => 'Esta candidatura não foi recusada';

  @override
  String get errInvalidOffer => 'O salário deve ser maior que 0 e ter moeda';

  @override
  String get errMinutesFile => 'A ata deve ser Word ou Excel';

  @override
  String nInterviewScheduled(String position, String time) {
    return 'Entrevista para $position em $time, toque para confirmar';
  }

  @override
  String nInterviewConfirmed(String time) {
    return 'Sua entrevista em $time está confirmada';
  }

  @override
  String nInterviewConfirmedHr(String position, String time) {
    return 'Entrevista para $position em $time confirmada';
  }

  @override
  String nInterviewProposed(String position, String time) {
    return 'Candidato a $position sugeriu $time';
  }

  @override
  String get projectTier => 'Nível';

  @override
  String get tierSmall => 'Nível 1 · Pequeno';

  @override
  String get tierMedium => 'Nível 2 · Médio';

  @override
  String get tierLarge => 'Nível 3 · Grande';

  @override
  String get tierStrategic => 'Nível 4 · Estratégico';

  @override
  String tierRule(int months, int members) {
    return 'Até $months meses, pelo menos $members pessoas';
  }

  @override
  String get warnRed => '≤ 1 mês restante';

  @override
  String get warnOrange => '≤ 6 meses restantes';

  @override
  String get warnYellow => '≤ 12 meses restantes';

  @override
  String get warnNotStarted => 'Não iniciado';

  @override
  String get warnAccepted => 'Aceito';

  @override
  String get warnNormal => 'Mais de 12 meses';

  @override
  String get projectCharts => 'Gráficos de projetos';

  @override
  String get chart2d => '2D';

  @override
  String get chart3d => '3D';

  @override
  String get chartTimeline => 'Linha do tempo';

  @override
  String get chartProgress => 'Progresso';

  @override
  String get chartMembers => 'Pessoas';

  @override
  String get chartValue => 'Valor';

  @override
  String get thousandUsd => 'mil USD';

  @override
  String get projectProposals => 'Propostas de projeto';

  @override
  String get projectNew => 'Novo projeto';

  @override
  String get wizardFiles => 'Contrato e imagem';

  @override
  String get wizardFilesHint =>
      'Envie o contrato (PDF ou Word, pelo modelo); a IA preenche o formulário. Sem contrato, preencha à mão a seguir.';

  @override
  String get wizardInfo => 'Dados do projeto';

  @override
  String get wizardMembers => 'Equipe';

  @override
  String get wizardSend => 'Enviar à diretoria';

  @override
  String get downloadContractTemplate => 'Baixar modelo de contrato';

  @override
  String get uploadContract => 'Enviar contrato';

  @override
  String get uploadProjectImage => 'Enviar imagem da obra';

  @override
  String get contractReadByAi =>
      'A IA leu o contrato e preencheu, confira a seguir';

  @override
  String get contractReadManual =>
      'Não foi possível ler o contrato, preencha à mão';

  @override
  String get projectName => 'Nome do projeto';

  @override
  String get customerName => 'Cliente';

  @override
  String get customerCompany => 'Empresa';

  @override
  String get customerIndividual => 'Pessoa física';

  @override
  String get customerContact => 'Contato do cliente (e-mail ou telefone)';

  @override
  String get contractType => 'Tipo de contrato';

  @override
  String get contractValue => 'Valor do contrato';

  @override
  String get depositAmount => 'Adiantamento';

  @override
  String get startDate => 'Início';

  @override
  String get endDate => 'Fim';

  @override
  String get acceptanceDate => 'Aceite';

  @override
  String get propErrName => 'Informe o nome do projeto';

  @override
  String get propErrCustomer => 'Informe o cliente';

  @override
  String get propErrValue => 'O valor deve ser maior que 0';

  @override
  String get propErrDeposit =>
      'O adiantamento não pode ser negativo nem maior que o valor';

  @override
  String get propErrDates => 'Informe início e fim';

  @override
  String get propErrStartPast => 'O início não pode ser no passado';

  @override
  String get propErrEndBeforeStart => 'O fim deve ser após o início';

  @override
  String get propErrAcceptance =>
      'O aceite deve ocorrer até 90 dias após o fim';

  @override
  String get propErrTooLong => 'Longo demais para este nível';

  @override
  String get propErrFewMembers => 'Pessoas insuficientes para este nível';

  @override
  String membersNeeded(int min, int picked) {
    return 'Pelo menos $min pessoas · $picked escolhidas';
  }

  @override
  String get suggestMembers => 'Sugestão de equipe da IA';

  @override
  String activeProjects(int count) {
    return '$count projetos ativos';
  }

  @override
  String get next => 'Avançar';

  @override
  String get back => 'Voltar';

  @override
  String get sendToExecutive => 'Enviar para aprovação';

  @override
  String get proposalSent => 'Proposta enviada, aguardando a diretoria';

  @override
  String get noProposals => 'Nenhuma proposta de projeto';

  @override
  String proposalVersion(int version) {
    return 'Versão $version';
  }

  @override
  String get propAwaitingExecutive => 'Aguardando diretoria';

  @override
  String get propAwaitingProposer => 'Aguardando proponente';

  @override
  String get propApproved => 'Aprovado';

  @override
  String get propRejected => 'Recusado';

  @override
  String get proposalEdit => 'Editar proposta';

  @override
  String get proposalNoteHint => 'Motivo ou o que mudar';

  @override
  String proposalApprovedDone(String id) {
    return 'Aprovado, projeto $id criado';
  }

  @override
  String get acceptEdits => 'Aceitar alterações';

  @override
  String get withdrawProposal => 'Retirar proposta';

  @override
  String get waitingOtherSide => 'Aguardando a outra parte';

  @override
  String get openContract => 'Abrir contrato';

  @override
  String get openImage => 'Abrir imagem';

  @override
  String get openProject => 'Abrir projeto';

  @override
  String get propActSubmitted => 'Enviada';

  @override
  String get propActCounter => 'Alterada';

  @override
  String get propActApprove => 'Aprovada';

  @override
  String get propActReject => 'Recusada';

  @override
  String get propActWithdraw => 'Retirada';

  @override
  String todoProposals(int count) {
    return '$count propostas de projeto para revisar';
  }

  @override
  String nProjectProposed(String name) {
    return 'Nova proposta de projeto: $name';
  }

  @override
  String nProjectCountered(String name) {
    return 'A diretoria alterou $name, confirme';
  }

  @override
  String nProjectApproved(String name) {
    return 'Projeto $name aprovado e criado';
  }

  @override
  String nProjectRejected(String name) {
    return 'Proposta $name recusada';
  }

  @override
  String get workCalendar => 'Calendário de trabalho';

  @override
  String get clockStats => 'Gráficos de ponto';

  @override
  String shiftHours(String start, String end) {
    return 'Turno $start–$end';
  }

  @override
  String get errShiftEnded =>
      'O turno terminou, não é mais possível registrar entrada';

  @override
  String get errTooManyFiles => 'No máximo 5 arquivos por pedido';

  @override
  String get errFileType => 'Este tipo de arquivo não é aceito';

  @override
  String get addEvidence => 'Adicionar comprovante';

  @override
  String viewOriginalLeave(int count) {
    return 'Ver originais ($count)';
  }

  @override
  String get evidenceUploaded =>
      'Comprovante adicionado, resumo da IA atualizado';

  @override
  String get noEvidence => 'Nenhum comprovante';

  @override
  String get aiLeaveSummary => 'Resumo dos comprovantes pela IA';

  @override
  String get evidenceMatches => 'Confere com o pedido';

  @override
  String get evidenceCheck => 'Verificar com atenção';

  @override
  String get calWorked => 'Trabalhado';

  @override
  String get calLeave => 'Folga';

  @override
  String get calHoliday => 'Feriado';

  @override
  String get calAbsent => 'Ausente';

  @override
  String get calScheduled => 'Escalado';

  @override
  String calLeaveOfType(String type) {
    return 'Folga: $type';
  }

  @override
  String get noShiftThisDay => 'Sem turno neste dia';

  @override
  String estimatedDayPay(String amount) {
    return 'Ganho estimado do dia: $amount';
  }

  @override
  String estimatedMonthPay(String amount) {
    return 'Ganho estimado pelas horas: $amount';
  }

  @override
  String get payEstimateHint =>
      'Salário base, 26 dias úteis, hora extra 150%; antes de seguro e impostos';

  @override
  String get projectsThisDay => 'Projetos neste dia';

  @override
  String get statsScopeRegion => 'Toda a região';

  @override
  String get statsScopeMine => 'Meus';

  @override
  String get statsDays => 'Dias registrados';

  @override
  String get statsLate => 'Atrasos';

  @override
  String get statsByWeekday => 'Por dia da semana';

  @override
  String get statsByHour => 'Horário de entrada';

  @override
  String get statsByMonth => 'Dias e atrasos por mês';

  @override
  String get errPayrollTooEarly =>
      'Este período ainda não abriu: o mês M paga a partir do dia 10 do mês seguinte';

  @override
  String get errAmountLowered => 'O salário proposto só pode manter ou subir';

  @override
  String get errNotHigher => 'O salário pedido deve ser maior que o atual';

  @override
  String get errNoSalary => 'Ainda não há salário base cadastrado';

  @override
  String get errAwaitingAck => 'O relatório anterior aguarda confirmação';

  @override
  String get acknowledge => 'Confirmar';

  @override
  String get byDay => 'Dia';

  @override
  String get byMonth => 'Mês';

  @override
  String get byYear => 'Ano';

  @override
  String get costs => 'Custos';

  @override
  String get export => 'Exportar';

  @override
  String get exportExcel => 'Exportar Excel';

  @override
  String get exportPdf => 'Exportar PDF';

  @override
  String exportedAt(String time) {
    return 'Exportado em $time';
  }

  @override
  String get exportId => 'Código';

  @override
  String get exportPeriod => 'Período';

  @override
  String get exportRank => 'Posição';

  @override
  String get exportMargin => 'Margem';

  @override
  String get exportCurrency => 'Moeda';

  @override
  String get exportRevenueUsd => 'Receita (USD)';

  @override
  String get exportCostUsd => 'Custos (USD)';

  @override
  String exportFinanceTitle(int year) {
    return 'Receitas e custos $year';
  }

  @override
  String get financeAnalytics => 'Análise';

  @override
  String get materialCost => 'Materiais';

  @override
  String get payrollCost => 'Folha';

  @override
  String get materialsUsed => 'Materiais usados';

  @override
  String get revenueByStage => 'Receita por etapa';

  @override
  String get projectProfitRanking => 'Projetos por lucro';

  @override
  String get projectSalaryShares => 'Pagamento do projeto por pessoa';

  @override
  String get overtimePay => 'Horas extras';

  @override
  String get insuranceDeduction => 'Previdência';

  @override
  String get incomeTax => 'Imposto de renda';

  @override
  String get salaryGrowth => 'Salário ao longo do tempo';

  @override
  String salaryGrowthRate(String rate, int count) {
    return 'Líquido $rate em $count períodos';
  }

  @override
  String payrollOpensOn(String period, String date) {
    return 'A folha de $period abre em $date';
  }

  @override
  String get raiseRequests => 'Pedidos de aumento';

  @override
  String get raiseRequestsHint => 'Enviar, encaminhar, aprovar';

  @override
  String get newRaiseRequest => 'Pedir aumento';

  @override
  String get noRaiseRequests => 'Nenhum pedido de aumento';

  @override
  String get proposedSalary => 'Salário base proposto';

  @override
  String raiseMinimum(String amount) {
    return 'No mínimo $amount';
  }

  @override
  String get raiseReason => 'Motivo (resultados, novas funções...)';

  @override
  String get raiseActionTitle => 'Salário e nota';

  @override
  String get raiseSent => 'Pedido enviado';

  @override
  String get raiseForwarded => 'Encaminhado para aprovação';

  @override
  String get raiseApprovedDone => 'Aprovado, salário aumentado';

  @override
  String get raiseForward => 'Encaminhar';

  @override
  String get raiseReturn => 'Devolver';

  @override
  String get raiseEdit => 'Editar valor';

  @override
  String get raiseAwaitingHr => 'Com o RH';

  @override
  String get raiseAwaitingApprover => 'Aguardando aprovação';

  @override
  String get raiseAwaitingEmployee => 'Devolvido ao funcionário';

  @override
  String get raiseWithdrawn => 'Retirado';

  @override
  String raiseRequestedFirst(String amount) {
    return 'Pedido inicial $amount';
  }

  @override
  String get reportSubmissions => 'Relatórios à diretoria';

  @override
  String get reportSubmissionsHint => 'Relatórios de RH e financeiro';

  @override
  String get reportHr => 'RH';

  @override
  String get reportFinance => 'Financeiro';

  @override
  String get noReports => 'Nenhum relatório';

  @override
  String get submitReport => 'Enviar relatório';

  @override
  String submitReportTitle(String period) {
    return 'Enviar relatório de $period';
  }

  @override
  String get reportWaitingAck => 'Aguardando confirmação';

  @override
  String get reportSent => 'Relatório enviado';

  @override
  String get reportAcknowledged => 'Relatório confirmado';

  @override
  String get returnReport => 'Devolver relatório';

  @override
  String get reportStatusSubmitted => 'Aguardando';

  @override
  String get reportStatusAcknowledged => 'Confirmado';

  @override
  String get reportStatusReturned => 'Devolvido';

  @override
  String reportPeriod(String period) {
    return 'Relatório de $period';
  }

  @override
  String reportHeadcount(int people, int departments) {
    return '$people funcionários, $departments departamentos';
  }

  @override
  String reportUnassigned(int count) {
    return '$count sem departamento';
  }

  @override
  String reportNominations(int pending, int approved) {
    return 'Promoções: $pending pendentes, $approved aprovadas';
  }

  @override
  String get resignations => 'Pedido de demissão';

  @override
  String get resignationsHint => 'Enviar e acompanhar demissões';

  @override
  String get newResignation => 'Pedir demissão';

  @override
  String get resignationLastDay => 'Último dia de trabalho';

  @override
  String resignationLastDayOn(String date) {
    return 'Último dia: $date';
  }

  @override
  String get resignationReason => 'Motivo da saída';

  @override
  String resignationNotice(int days) {
    return 'Aviso prévio de pelo menos $days dias';
  }

  @override
  String get resignationSent => 'Pedido enviado ao RH';

  @override
  String get noResignations => 'Nenhum pedido de demissão';

  @override
  String get resignationPending => 'Aguardando RH';

  @override
  String get resignationApproved => 'Aprovado, cumprindo aviso';

  @override
  String get resignationCompleted => 'Desligado';

  @override
  String get resignationWithdrawn => 'Retirado';

  @override
  String get resignationWithdraw => 'Retirar';

  @override
  String get resignationComplete => 'Concluir desligamento';

  @override
  String resignationCompleteConfirm(String name) {
    return 'O cadastro de $name será arquivado e removido de todos os projetos. Continuar?';
  }

  @override
  String get resignationCompletedDone =>
      'Desligamento concluído, cadastro arquivado';

  @override
  String get errNoticeTooShort =>
      'O último dia deve ser daqui a pelo menos 30 dias';

  @override
  String get errBeforeLastDay => 'O último dia de trabalho ainda não chegou';

  @override
  String get exportCsv => 'Exportar CSV';

  @override
  String get exportJson => 'Exportar JSON';

  @override
  String get auditCharts => 'Gráficos';

  @override
  String get auditFilter => 'Filtro detalhado';

  @override
  String get auditService => 'Serviço';

  @override
  String get auditEventType => 'Tipo de evento';

  @override
  String get auditTime => 'Momento';

  @override
  String get auditFromTime => 'De';

  @override
  String get auditToTime => 'Até';

  @override
  String get anyTime => 'Qualquer';

  @override
  String get anomalyAny => 'Anomalias';

  @override
  String get anomalyAfterHours => 'Fora do horário (22h–6h)';

  @override
  String get anomalyFailure => 'Falha ou recusa';

  @override
  String get auditTotal => 'Total de eventos';

  @override
  String get auditByRegion => 'Por região';

  @override
  String get auditByHour => 'Por hora local (vermelho é fora do horário)';

  @override
  String get auditByDay => 'Por dia';

  @override
  String get auditByType => 'Tipos de evento mais comuns';

  @override
  String get auditByService => 'Por serviço';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get auditSignedExport => 'CSV com SHA-256';

  @override
  String get approvalInbox => 'Caixa de aprovações';

  @override
  String get approvalInboxHint =>
      'Projetos, promoções e aumentos de todas as regiões';

  @override
  String get approvalKindProject => 'Projeto';

  @override
  String get approvalKindPromotion => 'Promoção';

  @override
  String get approvalKindRaise => 'Aumento';

  @override
  String get noApprovals => 'Nada aguardando aprovação';

  @override
  String approvalWaiting(int count) {
    return '$count aguardando aprovação';
  }

  @override
  String approvalRegionsDown(String regions) {
    return 'Sem dados de: $regions';
  }

  @override
  String get approvalByRegion => 'Pendentes por região';

  @override
  String approvalPromotionLine(String position, String percent) {
    return 'Para $position, +$percent% de salário';
  }

  @override
  String get approvalDone => 'Decisão registrada';

  @override
  String approvalConfirm(String title) {
    return 'Aprovar $title?';
  }

  @override
  String approvalRejectConfirm(String title) {
    return 'Recusar $title?';
  }

  @override
  String get approvalColKind => 'Tipo';

  @override
  String get approvalColTitle => 'Assunto';

  @override
  String get approvalColDetail => 'Detalhes';

  @override
  String get approvalColUpdated => 'Atualizado';

  @override
  String get jobPositions => 'Vagas';

  @override
  String get jobPositionsHint =>
      'Vagas, quantidade e candidatos por aderência da IA';

  @override
  String get newJobPosition => 'Nova vaga';

  @override
  String get editJobPosition => 'Editar vaga';

  @override
  String get noJobPositions => 'Nenhuma vaga ainda';

  @override
  String get positionTitle => 'Cargo';

  @override
  String get positionDepartment => 'Departamento';

  @override
  String get positionHeadcount => 'Pessoas necessárias';

  @override
  String get positionDescription => 'Descrição';

  @override
  String get positionRequirements => 'Requisitos';

  @override
  String get positionRequirementsHint =>
      'A IA avalia cada CV com base nestes requisitos';

  @override
  String get positionOpen => 'Aberta';

  @override
  String get positionFilled => 'Preenchida';

  @override
  String get positionClosed => 'Encerrada';

  @override
  String get closePosition => 'Encerrar vaga';

  @override
  String get reopenPosition => 'Reabrir';

  @override
  String get positionSaved => 'Vaga salva';

  @override
  String get positionApplicants => 'Candidatos (maior aderência primeiro)';

  @override
  String positionProgress(int hired, int headcount, int applicants) {
    return 'Contratados $hired/$headcount · $applicants candidatos';
  }

  @override
  String positionSlotsLeft(int count) {
    return '$count vagas';
  }

  @override
  String get choosePositions => 'Escolha as vagas';

  @override
  String get choosePositionsHint => 'Toque para escolher';

  @override
  String choosePositionsHelper(int max) {
    return 'Uma ou mais, até $max';
  }

  @override
  String positionsChosen(int count) {
    return 'Concluir ($count)';
  }

  @override
  String get positionMatchTitle => 'Aderência a cada vaga (IA)';

  @override
  String get positionMatchPending => 'IA analisando';

  @override
  String get positionMatchNone => 'Sem análise';

  @override
  String get positionMatchStrengths => 'Atende';

  @override
  String get positionMatchGaps => 'Falta';

  @override
  String bestMatch(int score) {
    return '$score% aderente';
  }

  @override
  String get errNoPosition => 'Escolha pelo menos uma vaga';

  @override
  String get errTooManyPositions => 'No máximo 5 vagas';

  @override
  String get errPositionUnavailable => 'Esta vaga está encerrada ou preenchida';

  @override
  String get errPositionTitleExists =>
      'Já existe uma vaga aberta com esse nome';

  @override
  String get errInvalidHeadcount => 'Quantidade deve ser de 1 a 500';

  @override
  String errHeadcountBelowHired(int hired) {
    return '$hired já contratados';
  }

  @override
  String get errInvalidPosition => 'Informe o cargo e a quantidade';

  @override
  String nRaiseRequested(String employee) {
    return '$employee pediu aumento';
  }

  @override
  String nRaiseForwarded(String employee) {
    return 'O RH encaminhou o pedido de aumento de $employee para aprovação';
  }

  @override
  String get nRaiseApproved => 'Seu pedido de aumento foi aprovado';

  @override
  String get nRaiseRejected => 'Seu pedido de aumento foi recusado';

  @override
  String get nRaiseReturned =>
      'Seu pedido de aumento foi devolvido para ajustes';

  @override
  String nReportSubmitted(String report, String period) {
    return 'Novo relatório $report de $period para confirmar';
  }

  @override
  String nReportAcknowledged(String report, String period) {
    return 'Relatório $report de $period confirmado';
  }

  @override
  String nReportReturned(String report, String period) {
    return 'Relatório $report de $period devolvido, veja a nota';
  }

  @override
  String nResignationRequested(String employee, String date) {
    return '$employee pediu demissão, último dia $date';
  }

  @override
  String nResignationApproved(String date) {
    return 'Seu pedido de demissão foi aprovado, último dia $date';
  }

  @override
  String get nResignationRejected => 'Seu pedido de demissão não foi aprovado';

  @override
  String nResignationWithdrawn(String employee) {
    return '$employee retirou o pedido de demissão';
  }

  @override
  String get reportKindHr => 'RH';

  @override
  String get reportKindFinance => 'financeiro';

  @override
  String get openFullPage => 'Abrir página completa';

  @override
  String get requestAlreadyHandled => 'Este pedido já foi tratado';

  @override
  String get requestFrom => 'De';

  @override
  String get waitingSuperior => 'Aguardando superior';

  @override
  String get signupTitle => 'Criar conta de candidato';

  @override
  String get signupHint =>
      'Informe seus dados. Um código de 6 dígitos será enviado a este e-mail.';

  @override
  String get sendCode => 'Enviar código';

  @override
  String codeSentTo(String email) {
    return 'Código enviado para $email, veja também o Spam';
  }

  @override
  String get verificationCode => 'Código (6 dígitos)';

  @override
  String get newPassword => 'Senha';

  @override
  String get passwordRule => 'Pelo menos 8 caracteres com letras e números';

  @override
  String get confirmPassword => 'Repita a senha';

  @override
  String get createAccount => 'Confirmar e criar conta';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String resendIn(int seconds) {
    return 'Reenviar em ${seconds}s';
  }

  @override
  String get editDetails => 'Editar nome, e-mail, telefone';

  @override
  String get signupDone => 'Conta criada, faça login';

  @override
  String get changePassword => 'Alterar senha';

  @override
  String get passwordChanged => 'Senha alterada';

  @override
  String get profileViewed => 'Sua candidatura foi visualizada';

  @override
  String get profileViewedHint =>
      'O RH abriu sua candidatura, ela não pode mais ser editada';

  @override
  String get cvRequired => 'Anexe o CV (PDF) para salvar';

  @override
  String get accountDetails => 'Da sua conta cadastrada';

  @override
  String get errInvalidEmail => 'E-mail inválido';

  @override
  String get errInvalidName => 'Nome de 2 a 80 caracteres';

  @override
  String get errInvalidPhone => 'Telefone inválido';

  @override
  String get errWeakPassword =>
      'A senha precisa de 8+ caracteres com letras e números';

  @override
  String get errEmailTaken => 'Este e-mail já tem conta, faça login';

  @override
  String get errCodeTooSoon => 'Código recém-enviado, aguarde 60 segundos';

  @override
  String get errCodeExpired => 'Código expirado ou errado demais, peça outro';

  @override
  String get errWrongCode => 'Código incorreto';

  @override
  String get errSignupUnavailable => 'Não foi possível enviar e-mail agora';

  @override
  String get projectTime => 'Período';

  @override
  String get me => 'Eu';

  @override
  String myProjectPay(String amount) {
    return 'Meu pagamento no projeto: $amount';
  }

  @override
  String get mySchedule => 'Minha agenda';

  @override
  String myScheduleHint(int days) {
    return '$days dias trabalhados neste mês no projeto';
  }

  @override
  String myScheduleEarned(String amount) {
    return 'Valor estimado pelos dias: $amount';
  }

  @override
  String get notCheckedIn => 'Sem registro';

  @override
  String get contractRequired =>
      'Envie o contrato (PDF, Word) para a IA ler os dados';

  @override
  String get attachedBonuses =>
      'Bônus e descontos, últimos 12 meses (anexados)';

  @override
  String bonusNet(String amount) {
    return 'Saldo: $amount';
  }

  @override
  String moreItems(int count) {
    return 'e mais $count';
  }

  @override
  String get orgTree => 'Organograma';

  @override
  String get orgTreeSearch => 'Buscar pessoas ou cargos';

  @override
  String orgTreeSummary(int departments, int people) {
    return '$departments departamentos · $people pessoas';
  }

  @override
  String get orgTreeToggle => 'Recolher ou expandir tudo';

  @override
  String get level1 => 'Colaborador';

  @override
  String get level2 => 'Especialista, engenheiro';

  @override
  String get level3 => 'Líder, adjunto';

  @override
  String get level4 => 'Gerente';

  @override
  String get level5 => 'Diretor';

  @override
  String get level6 => 'Diretoria';

  @override
  String get noHigherPosition => 'Já está no nível mais alto';

  @override
  String get errNotHigherPosition => 'A promoção deve ser para nível acima';

  @override
  String get errUnknownPosition => 'Escolha um cargo da lista';

  @override
  String overtimeApprovedToday(String hours, String until) {
    return '$hours h de hora extra aprovadas: trabalho até $until conta';
  }

  @override
  String overtimePendingToday(String hours) {
    return 'Pedido de $hours h extra pendente: só conta após aprovação';
  }

  @override
  String get overtimeNoneToday =>
      'Sem hora extra aprovada: o tempo após o turno não conta';

  @override
  String get viewZoomIn => 'Aumentar zoom';

  @override
  String get viewZoomOut => 'Diminuir zoom';

  @override
  String get viewFromTop => 'Ver de cima';

  @override
  String get viewFromBottom => 'Ver de baixo';

  @override
  String get viewRotateLeft => 'Girar à esquerda';

  @override
  String get viewRotateRight => 'Girar à direita';

  @override
  String get viewReset => 'Redefinir visão';

  @override
  String get sectionGroup => 'Grupo';

  @override
  String get sectionAdmin => 'Administração';

  @override
  String get roleGroup => 'Nível do grupo';

  @override
  String get groupOverview => 'Visão geral do grupo';

  @override
  String get groupOverviewHint =>
      'Números por país, toque num país para detalhes';

  @override
  String get adminConsole => 'Administração de dados';

  @override
  String get adminConsoleHint =>
      'Contas, calendário, cargos, estatísticas, backups, SQL';

  @override
  String viewingRegion(String region) {
    return 'Visualizando: $region';
  }

  @override
  String get chooseRegion => 'Escolha a região';

  @override
  String get approvalKindLeave => 'Licença';

  @override
  String get approvalKindOvertime => 'Hora extra';

  @override
  String get approvalKindProfile => 'Alteração de perfil';

  @override
  String get approvalKindResignation => 'Demissão';

  @override
  String get groupTotals => 'Grupo inteiro';

  @override
  String get groupEmployees => 'Funcionários';

  @override
  String get groupRevenueYtd => 'Receita do ano (USD)';

  @override
  String get groupCostYtd => 'Custos do ano (USD)';

  @override
  String get groupRegionDown =>
      'Não foi possível carregar este país, puxe para tentar de novo';

  @override
  String get execActions => 'Agir diretamente';

  @override
  String get execChangePosition => 'Promover ou mudar cargo';

  @override
  String get execPromote => 'Promover';

  @override
  String get execChangeOnly => 'Mudar cargo';

  @override
  String get execNewPosition => 'Novo cargo';

  @override
  String get execNoHigherPosition => 'Não há cargo superior disponível';

  @override
  String get execReason => 'Motivo (fica na auditoria)';

  @override
  String get execReasonRequired => 'Motivo (obrigatório)';

  @override
  String get execSalary => 'Alterar salário base';

  @override
  String execCurrentSalary(String amount) {
    return 'Salário base atual: $amount';
  }

  @override
  String get execNewSalary => 'Novo salário base';

  @override
  String get execBonus => 'Bônus ou penalidade';

  @override
  String get execBonusKind => 'Bônus';

  @override
  String get execPenaltyKind => 'Penalidade';

  @override
  String get execAmount => 'Valor (na moeda do salário)';

  @override
  String get execApply => 'Aplicar agora';

  @override
  String get execAuditNote =>
      'Vale imediatamente, sem outra aprovação; registrado na auditoria com seu nome.';

  @override
  String get execApplied => 'Aplicado e registrado na auditoria';

  @override
  String get nominationScope => 'Âmbito';

  @override
  String get nominationScopeRegion => 'Promoção no país';

  @override
  String get nominationScopeGroupHr => 'Para o RH do grupo';

  @override
  String get nominationScopeGroupFinance => 'Para as finanças do grupo';

  @override
  String get nominationGroupNote =>
      'Decidido pela diretoria do grupo; depois a pessoa atua em todas as regiões.';

  @override
  String get nominationToGroup => 'Nível do grupo';

  @override
  String get adminTabOverview => 'Visão geral';

  @override
  String get adminTabAccounts => 'Contas';

  @override
  String get adminTabCalendar => 'Calendário';

  @override
  String get adminTabPositions => 'Cargos';

  @override
  String get adminTabData => 'Dados';

  @override
  String get adminAccountsByRole => 'Contas por função';

  @override
  String adminAccountsTotal(int n) {
    return '$n contas';
  }

  @override
  String get adminDatabases => 'Bancos de dados';

  @override
  String adminDbLine(int tables, String rows, String size) {
    return '$tables tabelas · $rows linhas · $size';
  }

  @override
  String get adminActivity => 'Atividade dos últimos 14 dias (eventos)';

  @override
  String get adminRowsByDb => 'Linhas por banco';

  @override
  String get adminDbUnavailable => 'Não foi possível ler este banco';

  @override
  String get adminSearchAccounts => 'Buscar nome, e-mail, usuário';

  @override
  String get adminAccountDisabled => 'Bloqueada';

  @override
  String adminEditAccount(String name) {
    return 'Editar conta $name';
  }

  @override
  String get adminAccountEnabled => 'Permitir login';

  @override
  String get adminRoles => 'Funções';

  @override
  String get adminSaved => 'Salvo e registrado na auditoria';

  @override
  String get adminHolidays => 'Feriados';

  @override
  String get adminAddHoliday => 'Adicionar feriado';

  @override
  String get adminHolidayName => 'Nome do feriado';

  @override
  String adminHolidayRemove(String name) {
    return 'Remover o feriado $name?';
  }

  @override
  String get adminNoHolidays => 'Ainda sem feriados neste ano';

  @override
  String get adminShift => 'Horário do turno';

  @override
  String get adminShiftHint =>
      'Alterar entrada e saída de todos os turnos no período (a partir de hoje; o já registrado fica igual)';

  @override
  String get adminShiftChange => 'Alterar horário';

  @override
  String get adminShiftStart => 'Entrada';

  @override
  String get adminShiftEnd => 'Saída';

  @override
  String get adminShiftRange => 'Período';

  @override
  String adminShiftDone(int n) {
    return '$n turnos alterados';
  }

  @override
  String get adminAddPosition => 'Adicionar cargo';

  @override
  String get adminEditPosition => 'Editar cargo';

  @override
  String get adminPositionName => 'Nome do cargo';

  @override
  String get adminPositionLevel => 'Nível';

  @override
  String get adminCoefficient => 'Coeficiente salarial';

  @override
  String adminHolders(int n) {
    return '$n ocupantes';
  }

  @override
  String get adminDeletePosition => 'Excluir cargo';

  @override
  String get adminSql => 'Consulta SQL';

  @override
  String get adminSqlHint =>
      'Somente leitura por padrão; cada execução vai para a auditoria';

  @override
  String get adminSqlWrite => 'Permitir escrita (INSERT, UPDATE, DELETE)';

  @override
  String get adminSqlWriteConfirm =>
      'Isto altera dados reais e fica na auditoria. Executar?';

  @override
  String get adminSqlRun => 'Executar';

  @override
  String adminSqlRows(int n) {
    return '$n linhas';
  }

  @override
  String adminSqlAffected(int n) {
    return '$n linhas afetadas';
  }

  @override
  String get adminSqlTruncated => 'Mostrando as primeiras 500 linhas';

  @override
  String get adminTechnical => 'Detalhes técnicos';

  @override
  String get adminBackups => 'Backups';

  @override
  String get adminBackupNow => 'Fazer backup agora';

  @override
  String get adminBackupDone => 'Os dados da região foram salvos';

  @override
  String get adminBackupNone => 'Ainda sem backups';

  @override
  String get adminDownload => 'Baixar';

  @override
  String get errGroupOnly => 'Só a diretoria do grupo decide esta indicação';

  @override
  String get errSamePosition => 'O funcionário já ocupa este cargo';

  @override
  String get errInUse => 'Ainda há alguém neste cargo, não dá para excluir';

  @override
  String get errReadOnly =>
      'O comando altera dados; ative Permitir escrita se for intencional';

  @override
  String get errSqlError =>
      'O comando falhou, veja os detalhes técnicos abaixo';

  @override
  String get errUnknownDatabase => 'Escolha um banco da lista';

  @override
  String get errEmptySql => 'Digite um comando SQL';

  @override
  String get errStorageUnavailable =>
      'Armazenamento indisponível, tente mais tarde';

  @override
  String get errIdentityUnavailable =>
      'Serviço de contas indisponível, tente mais tarde';

  @override
  String get errOtherRegion => 'Esta conta é de outra região';

  @override
  String get errRoleNotAllowed => 'Você não pode dar ou tirar esta função';

  @override
  String get errSelfChange => 'Não é possível alterar a própria conta';

  @override
  String get errInvalidShift =>
      'Turno inválido: a saída deve ser após a entrada';

  @override
  String get errInvalidRange => 'Período inválido (no máximo um ano)';

  @override
  String get adminRemove => 'Remover';

  @override
  String get evClockedIn => 'Entrada registrada';

  @override
  String get evClockedOut => 'Saída registrada';

  @override
  String get evLeaveRequested => 'Licença solicitada';

  @override
  String get evLeaveApproved => 'Licença aprovada';

  @override
  String get evLeaveRejected => 'Licença recusada';

  @override
  String get evOvertimeRequested => 'Hora extra solicitada';

  @override
  String get evOvertimeApproved => 'Hora extra aprovada';

  @override
  String get evOvertimeRejected => 'Hora extra recusada';

  @override
  String get evHolidayAdded => 'Feriado adicionado';

  @override
  String get evHolidayRemoved => 'Feriado removido';

  @override
  String get evShiftChanged => 'Horário do turno alterado';

  @override
  String get evCandidateApplied => 'Candidatura recebida';

  @override
  String get evCandidateAnalyzed => 'CV analisado pela IA';

  @override
  String get evCandidateCvUploaded => 'CV enviado';

  @override
  String get evCandidateProfileUpdated => 'Perfil do candidato atualizado';

  @override
  String get evCandidateStatusChanged => 'Etapa do candidato alterada';

  @override
  String get evCandidateHired => 'Candidato contratado';

  @override
  String get evInterviewScheduled => 'Entrevista agendada';

  @override
  String get evInterviewConfirmed => 'Entrevista confirmada';

  @override
  String get evInterviewProposed => 'Outro horário de entrevista proposto';

  @override
  String get evPayslipIssued => 'Holerite emitido';

  @override
  String get evPayrollRunCompleted => 'Folha de pagamento concluída';

  @override
  String get evPayrollRunFailed => 'Folha de pagamento falhou';

  @override
  String get evPayrollRunNeedsAttention => 'Folha precisa de atenção';

  @override
  String get evPayrollExpenseRecorded => 'Despesa de folha registrada';

  @override
  String get evPayoutLogged => 'Pagamento registrado';

  @override
  String get evSalaryAgreed => 'Salário inicial acordado';

  @override
  String get evSalaryRaised => 'Salário aumentado';

  @override
  String get evSalaryChanged => 'Salário base alterado pela diretoria';

  @override
  String get evBonusGranted => 'Bônus concedido';

  @override
  String get evPenaltyApplied => 'Penalidade aplicada';

  @override
  String get evRaiseRequested => 'Aumento solicitado';

  @override
  String get evRaiseForwarded => 'Aumento encaminhado pelo RH';

  @override
  String get evRaiseApproved => 'Aumento aprovado';

  @override
  String get evRaiseRejected => 'Aumento recusado';

  @override
  String get evRaiseReturned => 'Aumento devolvido';

  @override
  String get evRaiseWithdrawn => 'Aumento retirado';

  @override
  String get evPromotionNominated => 'Promoção indicada';

  @override
  String get evPromotionApproved => 'Promoção aprovada';

  @override
  String get evPromotionRejected => 'Promoção recusada';

  @override
  String get evEmployeePromoted => 'Promovido pela diretoria';

  @override
  String get evPositionChanged => 'Cargo alterado pela diretoria';

  @override
  String get evPositionCreated => 'Cargo criado';

  @override
  String get evPositionUpdated => 'Cargo atualizado';

  @override
  String get evPositionDeleted => 'Cargo excluído';

  @override
  String get evEmployeeHired => 'Funcionário admitido';

  @override
  String get evEmployeeTransferred => 'Funcionário transferido';

  @override
  String get evEmployeeArchived => 'Funcionário arquivado';

  @override
  String get evEmployeeRestored => 'Funcionário restaurado';

  @override
  String get evDepartmentCreated => 'Departamento criado';

  @override
  String get evDepartmentDissolved => 'Departamento extinto';

  @override
  String get evDepartmentHeadChanged => 'Chefe do departamento alterado';

  @override
  String get evProfileChangeRequested => 'Alteração de perfil solicitada';

  @override
  String get evProfileChangeApproved => 'Alteração de perfil aprovada';

  @override
  String get evProfileChangeRejected => 'Alteração de perfil recusada';

  @override
  String get evResignationRequested => 'Demissão solicitada';

  @override
  String get evResignationApproved => 'Demissão aprovada';

  @override
  String get evResignationRejected => 'Demissão recusada';

  @override
  String get evResignationWithdrawn => 'Demissão retirada';

  @override
  String get evResignationCompleted => 'Desligamento concluído';

  @override
  String get evReportSubmitted => 'Relatório enviado';

  @override
  String get evReportAcknowledged => 'Relatório confirmado';

  @override
  String get evReportReturned => 'Relatório devolvido';

  @override
  String get evProjectCreated => 'Projeto criado';

  @override
  String get evProjectProposed => 'Projeto proposto';

  @override
  String get evProjectProposalApproved => 'Proposta de projeto aprovada';

  @override
  String get evProjectProposalRejected => 'Proposta de projeto recusada';

  @override
  String get evProjectProposalCountered => 'Proposta de projeto revisada';

  @override
  String get evProjectAccepted => 'Projeto aceito';

  @override
  String get evProjectMembersRemoved => 'Membros removidos do projeto';

  @override
  String get evAcceptanceRevenueRecorded => 'Receita de aceite registrada';

  @override
  String get evMaterialPurchased => 'Material comprado';

  @override
  String get evSupplierPaid => 'Fornecedor pago';

  @override
  String get evFinancePeriodClosed => 'Período financeiro fechado';

  @override
  String get evAdminSqlRead => 'Admin executou SQL (leitura)';

  @override
  String get evAdminSqlWrite => 'Admin alterou dados via SQL';

  @override
  String get evBackupCreated => 'Backup criado';

  @override
  String get evAccountChanged => 'Conta ou funções alteradas';

  @override
  String nAuditLog(String event, String by) {
    return 'Novo registro: $event$by';
  }

  @override
  String nAuditLogBy(String by) {
    return ' (por $by)';
  }

  @override
  String nPositionChanged(String position) {
    return 'Seu cargo agora é $position';
  }

  @override
  String nSalaryChanged(String amount) {
    return 'Seu novo salário base: $amount';
  }

  @override
  String nBonusGranted(String amount, String reason) {
    return 'Você recebeu bônus de $amount: $reason';
  }

  @override
  String nPenaltyApplied(String amount, String reason) {
    return 'Penalidade de $amount: $reason';
  }

  @override
  String get errProtectedDatabase =>
      'O banco de registros do admin não pode ser consultado aqui';

  @override
  String get errPastDate => 'A licença só pode começar a partir de amanhã';

  @override
  String get leaveAttach => 'Anexar comprovante (Word, PDF, imagem)';

  @override
  String approvalsOthers(int n) {
    return 'Pedidos de funcionários aguardando você ($n)';
  }

  @override
  String approvalsMine(int n) {
    return 'Seus pedidos aguardando o gestor ($n)';
  }

  @override
  String get requestMineTag => 'Seu';

  @override
  String get projectOverdue => 'Atrasado';

  @override
  String get reportMonth => 'Mês do relatório';

  @override
  String get reportMonthDone => 'já confirmado';

  @override
  String get errFuturePeriod => 'Só o mês atual ou anteriores';

  @override
  String get errPeriodAcknowledged =>
      'Este mês já foi confirmado e não pode ser reenviado';

  @override
  String get resignationAttachLetter => 'Anexar carta de demissão';

  @override
  String get resignationLetterHint =>
      'Obrigatório: foto, Word ou PDF (máx. 10 MB)';

  @override
  String resignationOpenLetter(String name) {
    return 'Abrir carta: $name';
  }

  @override
  String get resignationAiTitle => 'Análise da carta pela IA';

  @override
  String get resignationAiRetention => 'Ideias para reter';

  @override
  String get resignationAiConcerns => 'Atenção';

  @override
  String get resignationAiNote =>
      'Resumo da IA só para referência; quem decide é você';

  @override
  String get errLetterRequired =>
      'Anexe a carta de demissão (foto, Word ou PDF)';

  @override
  String get rcCareer => 'Carreira';

  @override
  String get rcSalary => 'Salário';

  @override
  String get rcWorkload => 'Carga de trabalho';

  @override
  String get rcManagement => 'Gestão';

  @override
  String get rcEnvironment => 'Ambiente';

  @override
  String get rcPersonal => 'Pessoal';

  @override
  String get rcHealth => 'Saúde';

  @override
  String get rcRelocation => 'Mudança';

  @override
  String get rcOther => 'Outro';

  @override
  String get auditExportNow => 'Exportar';

  @override
  String get auditRecord => 'Registro';

  @override
  String get auditActor => 'Feito por';

  @override
  String get auditData => 'Dados do evento';

  @override
  String get auditWhyFlagged => 'Por que foi sinalizado';

  @override
  String get anomalyAfterHoursWhy =>
      'Feito entre 22h e 6h no horário local, fora do expediente';

  @override
  String get anomalyFailureWhy =>
      'Falhou, foi recusado, compensado ou precisa de ação manual';

  @override
  String get auditAskAi => 'Pedir análise da IA';

  @override
  String get auditAiTitle => 'Análise da IA';

  @override
  String get auditChecks => 'O que verificar';

  @override
  String get auditLikelyBenign => 'Pode ser normal se';

  @override
  String get riskHigh => 'Risco alto';

  @override
  String get riskMedium => 'Risco médio';

  @override
  String get riskLow => 'Risco baixo';

  @override
  String get interviewTimePassed => 'Este horário já passou, proponha outro';
}
