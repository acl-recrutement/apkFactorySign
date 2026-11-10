class apiConfig {
  static const String baseUrl = 'https://backrecrgacl-production.up.railway.app';
  static Map<String, String> get defaultHeader => {
    'Content-Type': 'application/json',
  };
  static String loginUrl = "$baseUrl/api/manage/login";
  static String signContractUrl(int idContract) =>
      '$baseUrl/api/sendImage/signature/contract/$idContract';
  static String getUnsignedContractsUrl(int idUser, String site) =>
      '$baseUrl/api/contract/get/unsigned/$idUser?site=$site';
  static String getUnsignedRequisitionsUrl(String site) =>
      '$baseUrl/api/requisition/get/notval/$site';
}
