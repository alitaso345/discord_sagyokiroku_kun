require 'ed25519'
require 'json'

class DiscordSignatureVerifer
  def initialize(app, public_key)
    @app = app
    @verify_key = Ed25519::VerifyKey.new([public_key].pack('H*'))
  end

  def call(env)
    request = Rack::Request.new(env)
    body = request.body.read

    if env['PATH_INFO'] == '/interactions'
      timestamp = request.get_header('HTTP_X_SIGNATURE_TIMESTAMP')
      signature = request.get_header('HTTP_X_SIGNATURE_ED25519')
    
      return [400, {'content-type' => 'text/plain'}, ['Missing timestamp&signature header']] unless timestamp && signature
    
      begin
        is_verified = @verify_key.verify([signature].pack('H*'), timestamp + body)
      rescue Ed25519::VerifyError
        is_verified = false
      end

      # 署名が無効な場合は401エラーを返す
      return [401, {'content-type' => 'text/plain'}, ['Not verified']] unless is_verified
  
      # DiscordのPINGリクエストの場合、ACKとしてtype 1の応答を返す
      if JSON.parse(body)['type'] == 1
        return [200, { 'content-type' => 'application/json' }, [{ type: 1 }.to_json]]
      end
    end

    # 通常リクエストは次の処理に渡す
    env['rack.input'] = StringIO.new(body)
    @app.call(env)
  end
end