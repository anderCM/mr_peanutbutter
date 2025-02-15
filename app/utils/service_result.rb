class ServiceResult
  attr_reader :success, :data, :error_message, :error_code, :http_status

  def initialize(success:, data: nil, error_message: nil, error_code: nil, http_status: 200)
    @success       = success
    @data          = data
    @error_message = error_message
    @error_code    = error_code
    @http_status   = http_status
  end

  def success?
    @success
  end
end
