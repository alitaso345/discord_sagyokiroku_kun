class DiscordSignatureVerifer
  def initialize(app, public_key)
    @app = app
    @verify_key = Ed25519::VerifyKey.new([public_key].pack('H*'))
  end

  def call(env)
    if env['PATH_INFO'] == '/interactions'
      request = Rack::Request.new(env)
      timestamp = request.get_header('HTTP_X_SIGNATURE_TIMESTAMP')
      signature = request.get_header('HTTP_X_SIGNATURE_ED25519')
      body = request.body.read
    
      return [400, {'Content-Type' => 'text/plain'}, ['Missing timestamp&signature header']] unless timestamp && signature
    
      begin
        is_verified = @verify_key.verify([signature].pack('H*'), timestamp + body)
      rescue Ed25519::VerifyError
        is_verified = false
      end
    
      # 署名が無効な場合は401エラーを返す
      return [401, {'Content-Type' => 'text/plain'}, ['Not verified']] unless is_verified
  
      # DiscordのPINGリクエストの場合、ACKとしてtype 1の応答を返す
      if JSON.parse(body)['type'] == 1
        return [200, { 'Content-Type' => 'application/json' }, [{ type: 1 }.to_json]]
      end
    end

    # 通常リクエストは次の処理に渡す
    env['rack.input'] = StringIO.new(body)
    @app.call(env)
  end
end