require 'rails_helper'

describe MobileApp::API do
  describe '取得系API' do

    describe '利用者取得API' do
      let(:url) { '/api/users/self' }
      let(:response_body) do
        {
          id: 2,
          login_id: "test",
          name: "test",
          email: "test@example.com",
        }
      end

      context '正常系' do
        it_behaves_like 'GET -> 200応答'
      end

      context 'ID不正(文字列)' do
        let(:url) { '/api/users/aaa' }
        it_behaves_like 'GET -> 400応答'
      end

      context '認証エラー（トークン未指定）' do
        it_behaves_like 'GET -> 401応答'
      end

      context '認可されないリソースへの要求' do
        let(:url) { '/api/users/1' }
        it_behaves_like 'GET -> 403応答'
      end

      context '存在しないリソースへの要求' do
        let(:url) { '/api/users/99999' }
        it_behaves_like 'GET -> 404応答'
      end

      context 'Method不正（POST）' do
        it_behaves_like '405応答(POST)'
      end

      context 'Method不正（PUT）' do
        it_behaves_like '405応答(PUT)'
      end

      context 'Method不正（DELETE）' do
        it_behaves_like '405応答(DELETE)'
      end

    end #利用者取得API


    describe '監視モード取得API' do
      let(:url) { '/api/houses/self/monitoring_mode' }
      let(:response_body) do
        {
          mode: (1..3)
        }
      end

      context '正常系' do
        it_behaves_like 'GET -> 200応答'
        it '取得結果はDBの値と一致する' do
          get url, nil, { 'Authorization': "bearer #{@token}"}
          mode = JSON.parse(response.body).fetch("mode")
          expect(mode).to eq Hgw.owned_by(@user).first.status.mode
        end
      end

      context '認証エラー（トークン未指定）' do
        it_behaves_like 'GET -> 401応答'
      end

      context '認可されないリソースへの要求' do
        let(:url) { '/api/houses/hgw2/monitoring_mode' }
        it_behaves_like 'GET -> 403応答'
      end

      context '存在しないリソースへの要求' do
        let(:url) { '/api/houses/hgw5/monitoring_mode' }
        it_behaves_like 'GET -> 404応答' 
      end

      context 'Method不正（POST）' do
        it_behaves_like '405応答(POST)'
      end

      context 'Method不正（DELETE）' do
        it_behaves_like '405応答(DELETE)'
      end

      xcontext 'HGWから応答なし（IPアドレス変更で代替）' do
        let(:prep) { House.find('hgw1').update(ip_address: '192.168.0.1') }
        it_behaves_like 'GET -> 500応答' 
      end

    end #監視モード取得API


    describe '環境データ取得API' do
      let(:url) { '/api/rooms/1/environmental_info' }
      let(:response_body) do
        {
          temperature: Float,
          humidity: Fixnum,
          illuminance: Fixnum
        }
      end

      context '正常系' do
        it_behaves_like 'GET -> 200応答'
      end

      context '対象の部屋に各種センサが配置されていない場合' do
        let(:url) { '/api/rooms/2/environmental_info' }
        let(:response_body) do
          {
            temperature: nil,
            humidity: nil,
            illuminance: nil
          }
        end
        it_behaves_like 'GET -> 200応答'
      end

      context 'ID不正（文字列)' do
        let(:url) { '/api/rooms/aaa/environmental_info' }
        it_behaves_like 'GET -> 400応答'
      end

      context '認証エラー（トークン未指定）' do
        it_behaves_like 'GET -> 401応答'
      end

      context '認可されないリソースへの要求' do
        let(:url) { '/api/rooms/4/environmental_info' }
        it_behaves_like 'GET -> 403応答'
      end

      context '存在しないリソースへの要求' do
        let(:url) { '/api/rooms/12345/environmental_info' }
        it_behaves_like 'GET -> 404応答'
      end

      context 'Method不正（POST）' do
        it_behaves_like '405応答(POST)'
      end

      context 'Method不正（PUT）' do
        it_behaves_like '405応答(PUT)'
      end

      context 'Method不正（DELETE）' do
        it_behaves_like '405応答(DELETE)'
      end

      xcontext 'HGWから応答なし（IPアドレス変更で代替）' do
        let(:prep) { House.find('hgw1').update(ip_address: '192.168.0.1') }
        it_behaves_like 'GET -> 500応答' 
      end

    end #環境データ取得API

    describe 'ライフログ取得API' do
      describe '1件取得' do  

        let(:response_body) do
          {
            id: Fixnum,
            event_type_id: 1..9,
            event_type_desc: String,
            house_name: String,
            occurred_at: String,
            user_name: wildcard_matcher,
            detected_device_name: wildcard_matcher,
            operations: [
              {
                operation_type_desc: String,
                target_device_name: String,
                operated_at: wildcard_matcher
              }
            ].ignore_extra_values!
          }
        end

        context '正常系' do
          let(:url) { '/api/users/self/events/51' }
          it_behaves_like 'GET -> 200応答'
        end
        
        context '不正なID(文字列)' do
          let(:url) { '/api/users/self/events/aaa' }
          it_behaves_like 'GET -> 400応答'
        end

        context '禁止されたリソースへの要求' do
          let(:url) { '/api/users/self/events/1850' }
          it_behaves_like 'GET -> 403応答'
        end

        context '存在しないリソースへの要求' do
          let(:url) { '/api/users/self/events/0' }
          it_behaves_like 'GET -> 404応答'
        end

      end # 1件取得
      
      describe '一覧取得' do  

        let(:page) { 1 }
        let(:per_page) { 20 }
        let(:url) { '/api/users/self/events' }
        let(:response_body) do
          {
            events: [
              {
                id: Fixnum,
                event_type_id: 1..9,
                event_type_desc: String,
                occurred_at: String,
              }
            ].ignore_extra_values!,
            has_next: Boolean 
          }
        end 
        
        describe 'パラメータなし' do
          context '正常系' do
            it_behaves_like 'GET -> 200応答'
            it_behaves_like 'ライフログの応答件数はページング指定に従う'
          end
        end

        describe 'per_page指定あり' do
          let(:url) { "/api/users/self/events?per_page=#{per_page}" }

          context '正常系(per_page=1)' do
            let(:per_page) { 1 }
            it_behaves_like 'GET -> 200応答'
            it_behaves_like 'ライフログの応答件数はページング指定に従う'
          end

          context '正常系(per_page=100)' do
            let(:per_page) { 100 }
            it_behaves_like 'GET -> 200応答'
            it_behaves_like 'ライフログの応答件数はページング指定に従う'
          end

          context 'per_page不正(値なし)' do
            let(:per_page) { }
            it_behaves_like 'GET -> 400応答'
          end

          context 'per_page不正(文字列)' do
            let(:per_page) { 'aa' }
            it_behaves_like 'GET -> 400応答'
          end

          context 'per_page不正(範囲外の数値　下限)' do
            let(:per_page) { 0 }
            it_behaves_like 'GET -> 400応答'
          end

          context 'per_page不正(範囲外の数値　上限)' do
            let(:per_page) { 101 }
            it_behaves_like 'GET -> 400応答'
          end

        end

        describe 'page指定あり' do
          let(:url) { "/api/users/self/events?page=#{page}" }

          context '正常系(page=2)' do
            let(:page) { 2 }
            it_behaves_like 'GET -> 200応答'
            it_behaves_like 'ライフログの応答件数はページング指定に従う'
          end

          context 'page不正(値なし)' do
            let(:page) { }
            it_behaves_like 'GET -> 400応答'
          end

          context 'page不正(文字列)' do
            let(:page) { 'aa' }
            it_behaves_like 'GET -> 400応答'
          end

          context 'page不正(負の整数)' do
            let(:page) { -1 }
            it_behaves_like 'GET -> 400応答'
          end

          context 'page不正(0)' do
            let(:page) { 0 } 
            it_behaves_like 'GET -> 400応答'
          end

        end

        describe 'per_page&page指定あり' do
          let(:url) { "/api/users/self/events?per_page=#{per_page}&page=#{page}" }

          context '正常系(per_page=30,page=2)' do
            let(:per_page) { 30 }
            let(:page) { 2 }
            it_behaves_like 'GET -> 200応答'
            it_behaves_like 'ライフログの応答件数はページング指定に従う'
          end

          context 'per_page&page不正(文字列)' do
            let(:per_page) { 'aa' }
            let(:page) { 'aa' }
            it_behaves_like 'GET -> 400応答'
          end
       
        end

        describe 'event_type_id指定あり' do
          let(:url) { "/api/users/self/events?&event_type_id=#{event_type_id}" }

          context '正常系' do
            let(:event_type_id) { 5 }
            it_behaves_like 'GET -> 200応答'
            it 'event_type_idで絞り込みがされており、かつ、ページ指定が有効' do
              get url, nil, { 'Authorization': "bearer #{@token}"}
              events = JSON.parse(response.body).fetch("events")
              expect(events.map { |item| item["event_type_id"] }.all? { |item| item == 5 }).to eq true 
              expect(events.count).to eq per_page
              expect(events.last.fetch("id")).to eq Event.where(['user_id = ? or ( house_id = ? and user_id is null )', @user, @user.house]).where(event_type_id: 5).page(page).per(per_page).order("id desc").last.id
            end
          end

          context '正常系(複数指定)' do
            let(:event_type_id) { "5,6,7,8" }
            it_behaves_like 'GET -> 200応答'
            it 'event_type_idで絞り込みがされており、かつ、ページ指定が有効' do
              get url, nil, { 'Authorization': "bearer #{@token}"}
              events = JSON.parse(response.body).fetch("events")
              expect(events.map { |item| item["event_type_id"] }.all? { |item| item.in? (5..8) }).to eq true 
              expect(events.count).to eq per_page
              expect(events.last.fetch("id")).to eq Event.where(['user_id = ? or ( house_id = ? and user_id is null )', @user, @user.house]).where(event_type_id: (5..8)).page(page).per(per_page).order("id desc").last.id
            end
          end

          context 'event_type_id不正(値なし)' do
            let(:event_type_id) { }
            it_behaves_like 'GET -> 400応答'
          end

          context 'event_type_id不正(文字列)' do
            let(:event_type_id) { "aa"}
            it_behaves_like 'GET -> 400応答'
          end
          
          context 'event_type_id不正(範囲外 0)' do
            let(:event_type_id) { 0 }
            it_behaves_like 'GET -> 400応答'
          end
          
          context 'event_type_id不正(範囲外 10)' do
            let(:event_type_id) { 10 }
            it_behaves_like 'GET -> 400応答'
          end

          context 'event_type_id不正(複数指定　区切り文字不正)' do
            let(:event_type_id) { "5 6 7 8" }
            it '複数指定の最初のみが有効' do
              get url, nil, { 'Authorization': "bearer #{@token}"}
              events = JSON.parse(response.body).fetch("events")
              expect(events.last.fetch("id")).to eq Event.where(['user_id = ? or ( house_id = ? and user_id is null )', @user, @user.house]).where(event_type_id: 5).page(page).per(per_page).order("id desc").last.id
            end
          end

          context 'event_type_id不正(複数指定　文字列　範囲外)' do
            let(:event_type_id) { "aa,0,1,10" }
            it_behaves_like 'GET -> 400応答'
          end

        end

        context '認証エラー（トークン未指定）' do
          it_behaves_like 'GET -> 401応答'
        end

        context 'Method不正（POST）' do
          it_behaves_like '405応答(POST)'
        end

        context 'Method不正（PUT）' do
          it_behaves_like '405応答(PUT)'
        end

        context 'Method不正（DELETE）' do
          it_behaves_like '405応答(DELETE)'
        end

      end # 一覧取得

    end #ライフログ取得API


    describe '監視状態取得API' do
      let(:url) { '/api/houses/self/monitoring_states' }
      let(:response_body) do
        {
          monitoring_mode: (1..3),
          monitoring_sensors: [
            {
              id: Fixnum,
              type: or_matcher("OcSensor", "MSensor"),
              room_id: Fixnum,
              location: String,
              enabled: Boolean,
              sensed_state: Boolean,
              monitoring_state: Boolean
            }
          ].ignore_extra_values!
        }
      end

      context '正常系' do
        it_behaves_like 'GET -> 200応答'
      end

      context '認証エラー（トークン未指定）' do
        it_behaves_like 'GET -> 401応答'
      end

      context 'Method不正（POST）' do
        it_behaves_like '405応答(POST)'
      end

      context 'Method不正（DELETE）' do
        it_behaves_like '405応答(DELETE)'
      end

      xcontext 'HGWから応答なし（IPアドレス変更で代替）' do
        let(:prep) { House.find('hgw1').update(ip_address: '192.168.0.1') }
        it_behaves_like 'GET -> 500応答' 
      end
    end #監視状態取得API


    describe '機器配置ツリー取得API' do
      let(:url) { '/api/houses/self/rooms' }
      let(:response_body) do
        {
          rooms: [
            {
              id: Fixnum,
              name: String,
              devices: [
                {
                  id: Fixnum,
                  type: String
                }
              ].ignore_extra_values!
            }
          ].ignore_extra_values!
        }
      end

      context '正常系' do
        it_behaves_like 'GET -> 200応答'
      end

      context '認証エラー（トークン未指定）' do
        it_behaves_like 'GET -> 401応答'
      end

      context 'Method不正（POST）' do
        it_behaves_like '405応答(POST)'
      end

      context 'Method不正（DELETE）' do
        it_behaves_like '405応答(DELETE)'
      end

    end #機器配置ツリー取得API


    describe '機器状態取得API' do
      let(:url) { '/api/devices/1' }

      describe 'エアコン' do
        let(:url) { '/api/devices/5' }

        context '正常系' do
          let(:response_body) do
            {
              auto: Boolean,
              power: Boolean,
              mode: (1..5),
              temperature: (18..31),
              volume: (0..8),
              on_timer: (2..4),
              off_timer: (2..4)
            }.ignore_extra_keys!
          end
          it_behaves_like 'GET -> 200応答'
        end

        context '入タイマ予約あり(絶対時刻)' do
          let(:response_body) do
            {
              on_timer: 3,
              start_time: String
            }.ignore_extra_keys!
          end
          it 'start_timeがレスポンスに含まれる' do
            AirStatus.find_by(device_id: 5).update(on_timer: 3)
            get url, nil, { 'Authorization': "bearer #{@token}"}
            expect(response.body).to match_json_expression(response_body)
          end
        end

        context '入タイマ予約あり(相対時刻)' do
          let(:response_body) do
            {
              on_timer: 4,
              start_time_relative: Fixnum
            }.ignore_extra_keys!
          end
          it 'start_time_relativeがレスポンスに含まれる' do
            AirStatus.find_by(device_id: 5).update(on_timer: 4, start_time_relative: 30)
            get url, nil, { 'Authorization': "bearer #{@token}"}
            expect(response.body).to match_json_expression(response_body)
          end
        end

        context '切タイマ予約あり(絶対時刻)' do
          let(:response_body) do
            {
              off_timer: 3,
              stop_time: String
            }.ignore_extra_keys!
          end
          it 'stop_timeがレスポンスに含まれる' do
            AirStatus.find_by(device_id: 5).update(off_timer: 3)
            get url, nil, { 'Authorization': "bearer #{@token}"}
            expect(response.body).to match_json_expression(response_body)
          end
        end

        context '切タイマ予約あり(相対時刻)' do
          let(:response_body) do
            {
              off_timer: 4,
              stop_time_relative: Fixnum
            }.ignore_extra_keys!
          end
          it 'stop_time_relativeがレスポンスに含まれる' do
            AirStatus.find_by(device_id: 5).update(off_timer: 4, stop_time_relative: 30)
            get url, nil, { 'Authorization': "bearer #{@token}"}
            expect(response.body).to match_json_expression(response_body)
          end
        end

      end #エアコン

      describe '人感センサ' do
        let(:url) { '/api/devices/3' }

        context '正常系' do
          let(:response_body) do
            {
              enabled: Boolean
            }
          end
          it_behaves_like 'GET -> 200応答'
        end
        
      end #人感センサ

      context '不正なデバイスの指定(Hgw)' do
        let(:url) { '/api/devices/1' }
        it_behaves_like 'GET -> 400応答'
      end

      context '不正なデバイスの指定(TSensor)' do
        let(:url) { '/api/devices/2' }
        it_behaves_like 'GET -> 400応答'
      end

      context '不正なデバイスの指定(ISensor)' do
        let(:url) { '/api/devices/4' }
        it_behaves_like 'GET -> 400応答'
      end

      context '不正なデバイスの指定(Tv)' do
        let(:url) { '/api/devices/6' }
        it_behaves_like 'GET -> 400応答'
      end

      context '不正なデバイスの指定(Light)' do
        let(:url) { '/api/devices/7' }
        it_behaves_like 'GET -> 400応答'
      end

      context '不正なデバイスの指定(EButton)' do
        let(:url) { '/api/devices/11' }
        it_behaves_like 'GET -> 400応答'
      end

      context '認証エラー（トークン未指定）' do
        it_behaves_like 'GET -> 401応答'
      end

      context '禁止されているリソースへのアクセス' do
        let(:url) { '/api/devices/12' }
        it_behaves_like 'GET -> 403応答'
      end

      context '存在しないリソースへのアクセス' do
        let(:url) { '/api/devices/99999999' }
        it_behaves_like 'GET -> 404応答'
      end

      context 'Method不正（POST）' do
        it_behaves_like '405応答(POST)'
      end

      context 'Method不正（DELETE）' do
        it_behaves_like '405応答(DELETE)'
      end

    end #機器状態取得API
 

    describe '宅内情報サマリ取得API' do
      let(:url) { '/api/houses/self/summary' }
      let(:response_body) do
        {
          hems: {
            forecast_charge: Fixnum,
            message: String
          },
          home_automation: {
            temperature: Float,
            humidity: Fixnum,
            illuminance: Fixnum
          },
          home_security: {
            monitoring_mode: (1..3),
            monitoring_sensors: [
              {
                id: Fixnum,
                type: or_matcher("OcSensor", "MSensor"),
                room_id: Fixnum,
                location: String,
                enabled: Boolean,
                sensed_state: Boolean,
                monitoring_state: Boolean
              }
            ].ignore_extra_values!
          },
          scene_select: {
            enabled: Boolean
          },
          life_log: {
            event_type_desc: String,
            occurred_at: String
          }
        }
      end

      context '正常系' do
        it_behaves_like 'GET -> 200応答'
      end

      context '認証エラー（トークン未指定）' do
        it_behaves_like 'GET -> 401応答'
      end

      context 'Method不正（POST）' do
        it_behaves_like '405応答(POST)'
      end

      context 'Method不正（DELETE）' do
        it_behaves_like '405応答(DELETE)'
      end

    end #宅内情報サマリ取得API

  end #取得系API
end
