### アプリケーション設定 ######
#デバイス種別定義
DEVICE_TYPES = {
  'ホームゲートウェイ(01)': 'Hgw',
  'エアコン(11)': 'Air',
  '照明(12)': 'Light',
  'テレビ(13)': 'Tv',
  '温度センサ(21)': 'TSensor',
  '湿度センサ(22)': 'HSensor',
  '照度センサ(23)': 'ISensor',
  '開閉センサ(24)': 'OcSensor',
  '人感センサ(25)': 'MSensor',
  '非常ボタン(26)': 'EButton'
}

AIR_MODES = {
  '自動': 1,
  '冷房': 2,
  '暖房': 3,
  '除湿': 4,
  '送風': 5
}


#イベント種別ID
ROOM_IN_EVENT_TYPE_ID = 1
ROOM_OUT_EVENT_TYPE_ID = 2
EMERGENCY_EVENT_TYPE_ID = 3
E_BUTTON_EVENT_TYPE_ID = 4
AIR_EVENT_TYPE_ID = 5
TV_EVENT_TYPE_ID = 6
LIGHT_EVENT_TYPE_ID = 7
HS_EVENT_TYPE_ID = 8
HA_EVENT_TYPE_ID = 9
GO_OUT_BO_EVENT_TYPE_ID = 10
GO_HOME_BO_EVENT_TYPE_ID = 11
WAKE_UP_BO_EVENT_TYPE_ID = 12
HA_SETTING_CHANGE_EVENT_TYPE_ID = 13


#操作種別ID
AIR_POWER_ON_OPERATION_TYPE_ID = 1
AIR_POWER_OFF_OPERATION_TYPE_ID = 2
AIR_TEMP_UP_OPERATION_TYPE_ID = 3
AIR_TEMP_DOWN_OPERATION_TYPE_ID = 4
AIR_MODE_CHANGE_OPERATION_TYPE_ID = 5
AIR_VOL_CHANGE_OPERATION_TYPE_ID = 6
AIR_TEMP_ADJUST_DOWN_OPERATION_TYPE_ID = 8
AIR_TEMP_ADJUST_UP_OPERATION_TYPE_ID = 9
AIR_ON_TIMER_SET_OPERATION_TYPE_ID = 10
AIR_OFF_TIMER_SET_OPERATION_TYPE_ID = 11
AIR_ON_TIMER_UNSET_OPERATION_TYPE_ID = 12
AIR_OFF_TIMER_UNSET_OPERATION_TYPE_ID = 13
AIR_ON_TIMER_RELATIVE_SET30_OPERATION_TYPE_ID = 14
AIR_OFF_TIMER_RELATIVE_SET30_OPERATION_TYPE_ID = 15
AIR_ON_TIMER_RELATIVE_SET60_OPERATION_TYPE_ID = 16
AIR_OFF_TIMER_RELATIVE_SET60_OPERATION_TYPE_ID = 17
AIR_SET_TEMPERATURE_OPERATION_TYPE_ID = 18
AIR_AUTO_ON_OPERATION_TYPE_ID = 19
AIR_AUTO_OFF_OPERATION_TYPE_ID = 20
MUSIC_PLAY_OPERATION_TYPE_ID = 47
LIGHT_ON_OPERATION_TYPE_ID = 62
LIGHT_OFF_OPERATION_TYPE_ID = 63
GET_TEMPERATURE_OPERATION_TYPE_ID = 91
GET_HUMIDITY_OPERATION_TYPE_ID = 92
GET_ILLUMINANCE_OPERATION_TYPE_ID = 93
HS_MODE_CHANGE_OPERATION_TYPE_ID = 101
HS_ENABLE_SENSOR_OPERATION_TYPE_ID = 103
HS_NOTIFY_CENTER = 105
HS_NOTIFY_USER = 106
HS_SIREN = 107

#エアコン運転モード
AUTO = 1
COOLING = 2
HEATING = 3
DRY = 4
BLAST = 5
OTHER = 6


#メッセージ定義
SUCCESS_MSG = "リモコンコードの送信に成功しました"
FAILURE_MSG = "リモコンコードの送信に失敗しました。<br>もう一度ボタンを押してください。"

#暑い、寒いボタンの設定温度変更幅
T_DELTA = 2

#家電操作成否判定用の各種閾値等
LIGHT_ON_CHECK_THRESHOLD_ILLUMINANCE = 200
DAYLIGHT_CHECK_THRESHOLD_ILLUMINANCE = 10000
AIR_ON_CHECK_WAIT_TIME = 180
AIR_OFF_CHECK_WAIT_TIME = 300
TEMPERATURE_DELTA_THRESHOLD = 1 
HUMIDITY_DELTA_THRESHOLD = 2
LOWER_LIMIT_HUMIDITY = 55

#通知メール
FROM = "no-reply.hires.fs@kyuden.co.jp"
SUBJECT = "【Hires FS】異常を検知"

#リトライ
RETRY_CHECKER_JOB_WAIT_SECONDS = 30
DEFAULT_RETRY_LIMIT = 3
DELAULT_RETRY_DELAY = 30


#その他
CSE_ID = 'CSE0001'
if Rails.env.development?
  HTTP_URL_HOST = "16.147.132.211"
#  HTTP_URL_HOST_INTERNAL = "16.147.132.211"
elsif Rails.env.production?
  HTTP_URL_HOST = "168.87.98.41"
#  HTTP_URL_HOST_INTERNAL = "30.168.112.11"
end


#### HGW IF関連 #########################################################################
###HGWクライアント設定
HGW_ENDPOINT_TEMPLATE = "http://%{ip_address}/ems/devices/"
REQUEST_XML_TEMPLATE =<<"EOF"
<?xml version="1.0" encoding="utf-8"?>
<Device>
  <Modules>
    %{modules_body}
  </Modules>
</Device>
EOF
HGW_DIGEST_USER = "hires"
HGW_DIGEST_PASSWORD = "feudu@iz4sei3Vee"
X_M2M_ORIGIN = CSE_ID

###クラウドサーバ設定
DIGEST_REALM = "secret"
CLOUD_DIGEST_USER = "hires"
CLOUD_DIGEST_PASSWORD = "gV5pNB*mUQ!x"
DIGEST_USERS = {
  CLOUD_DIGEST_USER => CLOUD_DIGEST_PASSWORD
           #     "dap" => Digest::MD5.hexdigest(["dap",REALM,"secret"].join(":"))}  #ha1 digest password
}


#### HGW simulator ######################################################################
#HGW simulator用Digest認証設定
HGW_DIGEST_REALM = "secret"        #TBD at 2015/12/22
HGW_DIGEST_USERS = { HGW_DIGEST_USER => HGW_DIGEST_PASSWORD }

#Event generator
#CLOUD_ENDPOINT = "http://%{host}:443/CSE0001/events" % { host: HTTP_URL_HOST_INTERNAL }
CLOUD_ENDPOINT = "http://30.168.112.11:443/CSE0001/events"

CREATE_EVENT_REQUEST_XML_TEMPLATE =<<"EOF"
<?xml version="1.0" encoding="UTF-8"?>
<cin>
  <cnf>application/xml:0</cnf>
  <con>
    <hgw_id><%= event.house_id %></hgw_id>
    <device_id><%= event.device_id %></device_id>
    <event_type_id><%= event.event_type_id %></event_type_id>
    <occurred_at><%= event.occurred_at %></occurred_at>
  </con>
</cin>
EOF

