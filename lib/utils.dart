class Utils {
  static String hostIP = "192.168.1.239:5887";
  static String fecthGroupNames =
      "http://$hostIP/ECScadaTrends/api/GroupName?GroupName=";
//live-trend
  static String fetchSelectedGroupData =
      "http://$hostIP/ECScadaTrends/API/GroupwithTrendsTimestamp?GroupName=";
//log-data
}
