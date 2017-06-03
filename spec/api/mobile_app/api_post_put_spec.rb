require 'rails_helper'

describe MobileApp::API do
  describe '更新系API' do

    describe '監視モード更新API' do
      let(:url) { '/api/houses/self/monitoring_mode' }
      let(:input_params) do
        { mode: 1 }
      end

      context '正常系(mode=1に更新)' do
        it '200応答' do
          put url, {mode: 1}, { 'Authorization': "bearer #{@token}"}
          expect(response.status).to eq 200
          expect(response.body).to eq ""
          expect(Hgw.owned_by(@user).first.mode).to eq 1
        end
      end

      context '正常系(mode=2に更新)' do
        it '200応答+開閉センサON' do
          OcSensor.owned_by(@user).each do |sensor|
            sensor.status.update enabled: false
          end
          expect{ put(url, {mode: 2}, { 'Authorization': "bearer #{@token}"}) }.to change{ Hgw.owned_by(@user).first.mode }.from(1).to(2)
          expect(response.status).to eq 200
          expect(response.body).to eq ""
          OcSensor.owned_by(@user).each do |sensor|
            expect(sensor.build_remote_device.enabled).to eq true 
          end
        end
      end

      context '正常系(mode=3に更新)' do
        it '200応答+開閉・人感センサON' do
          sensors = OcSensor.owned_by(@user) + MSensor.owned_by(@user)          
          sensors.each do |sensor|
            sensor.status.update enabled: false
          end
          expect{ put(url, {mode: 3}, { 'Authorization': "bearer #{@token}"}) }.to change{ Hgw.owned_by(@user).first.mode }.from(2).to(3)
          expect(response.status).to eq 200
          expect(response.body).to eq ""
          sensors.each do |sensor|
            expect(sensor.build_remote_device.enabled).to eq true
          end
        end
      end

      context 'リクエスト不正(modeが数字ではない)' do
        let(:input_params) do
          { mode: 'a' }
        end
        it_behaves_like 'PUT -> 400応答'
      end

      context 'リクエスト不正(modeが指定範囲外)' do
        let(:input_params) do
          { mode: 0 }
        end
        it_behaves_like 'PUT -> 400応答'
      end

      context '認証エラー（トークン未指定）' do
        it_behaves_like 'PUT -> 401応答'
      end

      context '認可されないリソースへの要求' do
        let(:url) { '/api/houses/hgw2/monitoring_mode' }
        it_behaves_like 'PUT -> 403応答'
      end

      context '存在しないリソースへの要求' do
        let(:url) { '/api/houses/hgw5/monitoring_mode' }
        it_behaves_like 'PUT -> 404応答' 
      end

      context 'Method不正（POST）' do
        it_behaves_like '405応答(POST)'
      end

      context 'Method不正（DELETE）' do
        it_behaves_like '405応答(DELETE)'
      end

      xcontext 'HGWから応答なし（IPアドレス変更で代替）' do
        let(:prep) { House.find('hgw1').update(ip_address: '192.168.0.1') }
        it_behaves_like 'PUT -> 500応答'
      end

    end #監視モード更新API

    describe '機器状態更新API' do
      let(:url) { '/api/devices/5' }
      let(:input_params) do
        {
          operation_type: 'power_on',
          mode: 1,
          temperature: 25,
          volume: 1
        }
      end

      describe 'エアコン' do
        let(:url) { '/api/devices/5' }
        let(:input_params) do
          {
            operation_type: 'power_on',
            mode: 1,
            temperature: 25,
            volume: 1
          }
        end
        let(:event_type_id) { 5 }
        
        context '正常系(電源ON)' do
          let(:input_params) do { operation_type: 'power_on' } end
          let(:operation_type_id) { 1 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(電源OFF)' do
          let(:input_params) do { operation_type: 'power_off' } end
          let(:operation_type_id) { 2 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(エアコンの運転モード変更確認(1:自動))' do
          let(:input_params) do { operation_type: 'mode_change', mode: 1 } end
          let(:operation_type_id) { 5 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(エアコンの運転モード変更確認(2:冷房))' do
          let(:input_params) do { operation_type: 'mode_change', mode: 2 } end
          let(:operation_type_id) { 5 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(エアコンの運転モード変更確認(3:暖房))' do
          let(:input_params) do { operation_type: 'mode_change', mode: 3 } end
          let(:operation_type_id) { 5 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(エアコンの運転モード変更確認(4:除湿))' do
          let(:input_params) do { operation_type: 'mode_change', mode: 4 } end
          let(:operation_type_id) { 5 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(エアコンの運転モード変更確認(5:送風))' do
          let(:input_params) do { operation_type: 'mode_change', mode: 5 } end
          let(:operation_type_id) { 5 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context 'リクエスト不正 - エアコンの運転モード変更確認(レンジ外(0))' do
          let(:input_params) do
            {
              operation_type: 'mode_change',
              mode: 0
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - エアコンの運転モード変更確認(レンジ外(6))' do
          let(:input_params) do
            {
              operation_type: 'mode_change',
              mode: 6
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - エアコンの運転モード変更確認(空文字)' do
          let(:input_params) do
            {
              operation_type: 'mode_change',
              mode: ''
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - エアコンの運転モード変更確認(英数字)' do
          let(:input_params) do
            {
              operation_type: 'mode_change',
              mode: 'a'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - エアコンの運転モード変更確認(modeなし)' do
          let(:input_params) do
            {
              operation_type: 'mode_change'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context '正常系(温度変更)' do
          let(:input_params) do { operation_type: 'temperature_change', temperature: 18 } end
          let(:operation_type_id) { 18 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(エアコンの設定温度変更確認(31))' do
          let(:input_params) do { operation_type: 'temperature_change', temperature: 31 } end
          let(:operation_type_id) { 18 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context 'リクエスト不正 - エアコンの設定温度変更確認(レンジ外(17))' do
          let(:input_params) do
            {
              operation_type: 'temperature_change',
              temperature: 17
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - エアコンの設定温度変更確認(レンジ外(32))' do
          let(:input_params) do
            {
              operation_type: 'temperature_change',
              temperature: 32
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - エアコンの設定温度変更確認(空文字)' do
          let(:input_params) do
            {
              operation_type: 'temperature_change',
              temperature: ''
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - エアコンの設定温度変更確認(英数字)' do
          let(:input_params) do
            {
              operation_type: 'temperature_change',
              temperature: 'a'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - エアコンの設定温度変更確認(temperatureなし)' do
          let(:input_params) do
            {
              operation_type: 'temperature_change',
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context '正常系(エアコンの風量(0(自動設定)))' do
          let(:input_params) do { operation_type: 'volume_change', volume: 0 } end
          let(:operation_type_id) { 6 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(エアコンの風量(8))' do
          let(:input_params) do { operation_type: 'volume_change', volume: 8 } end
          let(:operation_type_id) { 6 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context 'リクエスト不正 - エアコンの風量(レンジ外(-1))' do
          let(:input_params) do
            {
              operation_type: 'volume_change',
              volume: -1
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - エアコンの風量(レンジ外(9))' do
          let(:input_params) do
            {
              operation_type: 'volume_change',
              volume:10
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - エアコンの風量(空文字)' do
          let(:input_params) do
            {
              operation_type: 'volume_change',
              volume: ''
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - エアコンの風量(英数字)' do
          let(:input_params) do
            {
              operation_type: 'volume_change',
              volume: 'a'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - エアコンの風量(volumeなし)' do
          let(:input_params) do
            {
              operation_type: 'volume_change'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context '正常系(入タイマ予約（時間指定))' do
          let(:input_params) do { operation_type: 'on_timer_set', start_time: '2001-02-03T04:05:06+09:00' } end
          let(:operation_type_id) { 10 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context 'リクエスト不正 - 入タイマ予約（空文字))' do
          let(:input_params) do
            {
              operation_type: 'on_timer_set',
              start_time: ''
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - 入タイマ予約（英数字))' do
          let(:input_params) do
            {
              operation_type: 'on_timer_set',
              start_time: 'abc'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - 入タイマ予約（start_timeなし))' do
          let(:input_params) do
            {
              operation_type: 'on_timer_set'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context '正常系(入タイマ予約(30分後))' do
          let(:input_params) do { operation_type: 'on_timer_30_set' } end
          let(:operation_type_id) { 14 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(入タイマ予約(60分後))' do
          let(:input_params) do { operation_type: 'on_timer_60_set' } end
          let(:operation_type_id) { 16 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(入タイマ予約取消)' do
          let(:input_params) do { operation_type: 'on_timer_unset' } end
          let(:operation_type_id) { 12 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(切タイマ予約(時間指定))' do
          let(:input_params) do { operation_type: 'off_timer_set', stop_time: '2001-02-03T04:05:06+09:00' } end
          let(:operation_type_id) { 11 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context 'リクエスト不正 - 切タイマ予約（空文字))' do
          let(:input_params) do
            {
              operation_type: 'off_timer_set',
              start_time: ''
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - 切タイマ予約（英数字))' do
          let(:input_params) do
            {
              operation_type: 'off_timer_set',
              start_time: 'abc'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - 切タイマ予約（stop_timeなし))' do
          let(:input_params) do
            {
              operation_type: 'off_timer_set'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context '正常系(切タイマ予約(30分後))' do
          let(:input_params) do { operation_type: 'off_timer_30_set' } end
          let(:operation_type_id) { 15 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(切タイマ予約(60分後))' do
          let(:input_params) do { operation_type: 'off_timer_60_set' } end
          let(:operation_type_id) { 17 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(切タイマ予約取消)' do
          let(:input_params) do { operation_type: 'off_timer_unset' } end
          let(:operation_type_id) { 13 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(暑いボタン操作)' do
          let(:input_params) do { operation_type: 'hot' } end
          let(:operation_type_id) { 91 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(寒いボタン操作)' do
          let(:input_params) do { operation_type: 'cold' } end
          let(:operation_type_id) { 91 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(自動最適運転ON)' do
          it '200応答' do
            put url, {operation_type: 'auto_on'}, { 'Authorization': "bearer #{@token}"}
            expect(response.status).to eq 200
            expect(response.body).to eq ""
          end
        end

        context '正常系(自動最適運転OFF)' do
          it '200応答' do
            put url, {operation_type: 'auto_off'}, { 'Authorization': "bearer #{@token}"}
            expect(response.status).to eq 200
            expect(response.body).to eq ""
          end
        end

        context 'リクエスト不正(必須項目不正)' do
          let(:input_params) do
            {
              abc: 'power_on'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(フォーマット不正)' do
          let(:input_params) do
            {
              operation_type: 1
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - 大文字' do
          let(:input_params) do
            {
              operation_type: 'POWER_ON'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(空文字)' do
          let(:input_params) do
            {
              operation_type: ''
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(パラメータ不正)' do
          let(:input_params) do
            {
              operation_type: 'channel_13'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(TV操作操作リクエスト)' do
          let(:input_params) do
            {
              operation_type: 'power_switch'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(照明操作リクエスト)だがoperation_typeが正しいので正常' do
          it '200応答' do
            put url, {operation_type: 'power_on'}, { 'Authorization': "bearer #{@token}"}
            expect(response.status).to eq 200
            expect(response.body).to eq ""
          end
        end

        context 'リクエスト不正(人感センサ)' do
          let(:input_params) do
            {
              enabled: true
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(開閉センサ)' do
          let(:input_params) do
            {
              enabled: false
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end
      end #エアコン

      describe 'TV' do
        let(:url) { '/api/devices/6' }
        let(:input_params) do
          { operation_type: 'power_switch' }
        end

        let(:event_type_id) { 6 }

        context '正常系(電源ボタン操作)' do
          let(:input_params) do { operation_type: 'power_switch' } end
          let(:operation_type_id) { 31 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(音量UP)' do
          let(:input_params) do { operation_type: 'volume_up' } end
          let(:operation_type_id) { 32 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(音量DOWN)' do
          let(:input_params) do { operation_type: 'volume_down' } end
          let(:operation_type_id) { 33 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(選局（↑）ボタン操作)' do
          let(:input_params) do { operation_type: 'channel_up' } end
          let(:operation_type_id) { 34 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(選局（↓）ボタン操作)' do
          let(:input_params) do { operation_type: 'channel_down' } end
          let(:operation_type_id) { 35 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(チャンネル1を選局)' do
          let(:input_params) do { operation_type: 'channel_1' } end
          let(:operation_type_id) { 36 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(チャンネル2を選局)' do
          let(:input_params) do { operation_type: 'channel_2' } end
          let(:operation_type_id) { 37 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(チャンネル3を選局)' do
          let(:input_params) do { operation_type: 'channel_3' } end
          let(:operation_type_id) { 38 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(チャンネル4を選局)' do
          let(:input_params) do { operation_type: 'channel_4' } end
          let(:operation_type_id) { 39 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(チャンネル5を選局)' do
          let(:input_params) do { operation_type: 'channel_5' } end
          let(:operation_type_id) { 40 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(チャンネル6を選局)' do
          let(:input_params) do { operation_type: 'channel_6' } end
          let(:operation_type_id) { 41 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(チャンネル7を選局)' do
          let(:input_params) do { operation_type: 'channel_7' } end
          let(:operation_type_id) { 42 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(チャンネル8を選局)' do
          let(:input_params) do { operation_type: 'channel_8' } end
          let(:operation_type_id) { 43 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(チャンネル9を選局)' do
          let(:input_params) do { operation_type: 'channel_9' } end
          let(:operation_type_id) { 44 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(チャンネル10を選局)' do
          let(:input_params) do { operation_type: 'channel_10' } end
          let(:operation_type_id) { 45 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(チャンネル11を選局)' do
          let(:input_params) do { operation_type: 'channel_11' } end
          let(:operation_type_id) { 46 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(チャンネル12を選局)' do
          let(:input_params) do { operation_type: 'channel_12' } end
          let(:operation_type_id) { 47 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context 'リクエスト不正(必須項目不正)' do
          let(:input_params) do
            {
              abc: 'power_on'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(フォーマット不正)' do
          let(:input_params) do
            {
              operation_type: 1
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - 大文字' do
          let(:input_params) do
            {
              operation_type: 'POWER_SWITCH'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(空文字)' do
          let(:input_params) do
            {
              operation_type: ''
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(パラメータ不正)' do
          let(:input_params) do
            {
              operation_type: 'channel_13'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(エアコン操作リクエスト)' do
          let(:input_params) do
            {
              operation_type: 'power_on',
	      mode: 1,
	      temperature: 25,
	      volume: 1
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(照明操作リクエスト)' do
          let(:input_params) do
            {
              operation_type: 'power_on'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(人感センサ)' do
          let(:input_params) do
            {
              enabled: true
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(開閉センサ)' do
          let(:input_params) do
            {
              enabled: false
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end
      end

      describe '照明' do
        let(:url) { '/api/devices/7' }
        let(:input_params) do
          { operation_type: 'power_on' }
        end

        let(:event_type_id) { 7 }

        context '正常系(電源ON)' do
          let(:input_params) do { operation_type: 'power_on' } end
          let(:operation_type_id) { 62 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(電源OFF)' do
          let(:input_params) do { operation_type: 'power_off' } end
          let(:operation_type_id) { 63 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context 'リクエスト不正(必須項目不正)' do
          let(:input_params) do
            {
              abc: 'power_on'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(フォーマット不正)' do
          let(:input_params) do
            {
              operation_type: 1
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - 大文字' do
          let(:input_params) do
            {
              operation_type: 'POWER_ON'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(空文字)' do
          let(:input_params) do
            {
              operation_type: ''
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(パラメータ不正)' do
          let(:input_params) do
            {
              operation_type: 'channel_12'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(エアコン操作リクエスト)だがoperation_typeが正しいので正常' do
          it '200応答' do
            put url, {operation_type: 'power_on', mode: 1, temperature: 25, volume: 1}, { 'Authorization': "bearer #{@token}"}
            expect(response.status).to eq 200
            expect(response.body).to eq ""
          end
        end

        context 'リクエスト不正(TV操作操作リクエスト)' do
          let(:input_params) do
            {
              operation_type: 'power_switch'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(人感センサ)' do
          let(:input_params) do
            {
              enabled: true
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(開閉センサ)' do
          let(:input_params) do
            {
              enabled: false
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end
      end

      describe '人感センサ' do
        let(:url) { '/api/devices/3' }
        let(:input_params) do
          { enabled: true }
        end

        let(:event_type_id) { 8 }

        context '正常系(有効化) - 小文字' do
          let(:input_params) do { enabled: true } end
          let(:operation_type_id) { 103 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(無効化) - 小文字' do
          let(:input_params) do { enabled: false } end
          let(:operation_type_id) { 104 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context 'リクエスト不正 - 大文字' do
          let(:input_params) do
            {
              enabled: 'TRUE'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - 大文字' do
          let(:input_params) do
            {
              enabled: 'FALSE'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(必須項目不正)' do
          let(:input_params) do
            {
              abc: true
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(フォーマット不正)' do
          let(:input_params) do
            {
              enabled: 'abc'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(パラメータ不正)' do
          let(:input_params) do
            {
              operation_type: 'power_on'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(エアコン操作リクエスト)' do
          let(:input_params) do
            {
              operation_type: 'power_on',
              mode: 1,
              temperature: 25,
              volume: 1
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(TV操作操作リクエスト)' do
          let(:input_params) do
            {
              operation_type: 'power_switch'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(照明操作リクエスト)' do
          let(:input_params) do
            {
              operation_type: 'power_on'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end
      end

      describe '開閉センサ' do
        let(:url) { '/api/devices/9' }
        let(:input_params) do
          { enabled: true }
        end

        let(:event_type_id) { 8 }

        context '正常系(有効化) - 小文字' do
          let(:input_params) do { enabled: true } end
          let(:operation_type_id) { 103 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context '正常系(無効化) - 小文字' do
          let(:input_params) do { enabled: false } end
          let(:operation_type_id) { 104 }
          it_behaves_like '200応答+ライフログ生成'
        end

        context 'リクエスト不正 - 大文字' do
          let(:input_params) do
            {
              enabled: 'TRUE'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正 - 大文字' do
          let(:input_params) do
            {
              enabled: 'FALSE'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(必須項目不正)' do
          let(:input_params) do
            {
              abc: true
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(フォーマット不正)' do
          let(:input_params) do
            {
              enabled: 'abc'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(空文字)' do
          let(:input_params) do
            {
              enabled: ''
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(パラメータ不正)' do
          let(:input_params) do
            {
              operation_type: 'power_on'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(エアコン操作リクエスト)' do
          let(:input_params) do
            {
              operation_type: 'power_on',
              mode: 1,
              temperature: 25,
              volume: 1
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(TV操作操作リクエスト)' do
          let(:input_params) do
            {
              operation_type: 'power_switch'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end

        context 'リクエスト不正(照明操作リクエスト)' do
          let(:input_params) do
            {
              operation_type: 'power_on'
            }
          end
          it_behaves_like 'PUT -> 400応答'
        end
      end

      context '存在しないデバイスへの要求' do
        let(:url) { '/api/devices/12345' }
        it_behaves_like 'PUT -> 404応答'
      end

      context '認可されないデバイスへの要求' do
        let(:url) { '/api/devices/12' }
        it_behaves_like 'PUT -> 403応答'
      end

      context '不正デバイスへの要求(Hgw)' do
        let(:url) { '/api/devices/1' }
        it_behaves_like 'PUT -> 400応答'
      end

      context '不正デバイスへの要求(TSensor)' do
        let(:url) { '/api/devices/2' }
        it_behaves_like 'PUT -> 400応答'
      end

      context '不正デバイスへの要求(ISensor)' do
        let(:url) { '/api/devices/4' }
        it_behaves_like 'PUT -> 400応答'
      end

      context '不正デバイスへの要求(EButton)' do
        let(:url) { '/api/devices/11' }
        it_behaves_like 'PUT -> 400応答'
      end

      context 'Method不正（POST）' do
        it_behaves_like '405応答(POST)'
      end

      context 'Method不正（DELETE）' do
        it_behaves_like '405応答(DELETE)'
      end

      context '認証エラー（トークン未指定）' do
        it_behaves_like 'PUT -> 401応答'
      end

    end #機器状態更新API


    describe '一括操作API' do
      let(:url) { '/api/houses/self/bulk_operation' }
      let(:input_params) do
        { type: 1 }
      end

      context '正常系(外出)' do
        let(:input_params) do
          { type: 1 }
        end
        it_behaves_like 'POST -> 200応答'
      end

      context '正常系(在宅)' do
        let(:input_params) do
          { type: 2 }
        end
        it_behaves_like 'POST -> 200応答'
      end

      context '正常系(起床)' do
        let(:input_params) do
          { type: 3 }
        end
        it_behaves_like 'POST -> 200応答'
      end

      context 'リクエスト不正(typeeが数字ではない)' do
        let(:input_params) do
          { type: 'a' }
        end
        it_behaves_like 'POST -> 400応答'
      end

      context 'リクエスト不正(typeが指定範囲外)' do
        let(:input_params) do
          { type: 0 }
        end
        it_behaves_like 'POST -> 400応答'
      end

      context '認証エラー（トークン未指定）' do
        it_behaves_like 'POST -> 401応答'
      end

      context 'Method不正（GET）' do
        it_behaves_like '405応答(GET)'
      end

      context 'Method不正（PUT）' do
        it_behaves_like '405応答(PUT)'
      end

      context 'Method不正（DELETE）' do
        it_behaves_like '405応答(DELETE)'
      end

    end #一括操作API

  end #更新系API
end
