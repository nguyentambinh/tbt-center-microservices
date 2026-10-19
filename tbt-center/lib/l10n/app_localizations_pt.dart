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
  String get stepPay => 'Pagar pelo banco';

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
      'O banco não respondeu a tempo; o sistema concilia pela referência antes de pagar novamente';

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
}
