#共通
shared_examples '405応答(GET)' do
  it do
    get url, nil, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 405
  end
end
shared_examples '405応答(POST)' do
  it do
    post url, nil, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 405
  end
end
shared_examples '405応答(PUT)' do
  it do
    put url, nil, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 405
  end
end
shared_examples '405応答(DELETE)' do
  it do
    delete url, nil, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 405
  end
end

#取得系API
shared_examples 'GET -> 200応答' do
  it do
    get url, nil, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 200
    expect(response.body).to match_json_expression(response_body)
  end
end
shared_examples 'GET -> 400応答' do
  it do
    get url, nil, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 400
    expect(response.body).to match_json_expression(@error)
  end
end
shared_examples 'GET -> 401応答' do
  it do
    get url
    expect(response.status).to eq 401
    expect(response.body).to match_json_expression(@error)
  end
end
shared_examples 'GET -> 403応答' do
  it do
    get url, nil, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 403
    expect(response.body).to match_json_expression(@error)
  end
end
shared_examples 'GET -> 404応答' do
  it do
    get url, nil, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 404
    expect(response.body).to match_json_expression(@error)
  end
end
shared_examples 'GET -> 500応答' do
  it do
    prep
    get url, nil, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 500
    expect(response.body).to match_json_expression(@error)
  end
end
shared_examples 'ライフログの応答件数はページング指定に従う' do
  it do
    get url, nil, { 'Authorization': "bearer #{@token}"}
    events = JSON.parse(response.body).fetch("events")
    expect(events.count).to eq per_page
    expect(events.last.fetch("id")).to eq Event.where(['user_id = ? or ( house_id = ? and user_id is null )', @user, @user.house]).page(page).per(per_page).order("id desc").last.id
  end
end

#更新系API
shared_examples '200応答+ライフログ生成' do
  it do
    put url, input_params, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 200
    expect(response.body).to eq ""
    expect(Event.last.event_type_id).to eq event_type_id
    expect(Event.last.operations.first.operation_type_id).to eq operation_type_id
  end
end

shared_examples 'PUT -> 400応答' do
  it do
    put url, input_params, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 400
    expect(response.body).to match_json_expression(@error)
  end
end
shared_examples 'PUT -> 401応答' do
  it do
    put url, input_params
    expect(response.status).to eq 401
    expect(response.body).to match_json_expression(@error)
  end
end
shared_examples 'PUT -> 403応答' do
  it do
    put url, input_params, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 403
    expect(response.body).to match_json_expression(@error)
  end
end
shared_examples 'PUT -> 404応答' do
  it do
    put url, input_params, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 404
    expect(response.body).to match_json_expression(@error)
  end
end
shared_examples 'PUT -> 500応答' do
  it do
    prep
    put url, input_params, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 500
    expect(response.body).to match_json_expression(@error)
  end
end

shared_examples 'POST -> 200応答' do
  it do
    post url, input_params, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 200
    expect(response.body).to eq ""
  end
end

shared_examples 'POST -> 400応答' do
  it do
    post url, input_params, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 400
    expect(response.body).to match_json_expression(@error)
  end
end
shared_examples 'POST -> 401応答' do
  it do
    post url, input_params
    expect(response.status).to eq 401
    expect(response.body).to match_json_expression(@error)
  end
end
shared_examples 'POST -> 403応答' do
  it do
    post url, input_params, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 403
    expect(response.body).to match_json_expression(@error)
  end
end
shared_examples 'POST -> 404応答' do
  it do
    post url, input_params, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 404
    expect(response.body).to match_json_expression(@error)
  end
end
shared_examples 'POST -> 500応答' do
  it do
    prep
    post url, input_params, { 'Authorization': "bearer #{@token}"}
    expect(response.status).to eq 500
    expect(response.body).to match_json_expression(@error)
  end
end
