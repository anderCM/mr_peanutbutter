require "net/http"
require "uri"
require "json"

class CryptoPriceService
  # Values could be changed based on the requirements
  ALLOWED_COINS = ["bitcoin"].freeze
  ALLOWED_CURRENCIES = ["usd"].freeze
  DEFAULT_PRECISION = 2

  def initialize(coin_ids:, vs_currency: "usd")
    @coin_ids = filter_coin_ids(coin_ids)
    @vs_currency = vs_currency
  end

  def self.call(coin_ids:, vs_currency: "usd")
    new(coin_ids:, vs_currency:).call
  end

  def call
    validate_values
    req_params = build_request
    response = make_request(req_params)

    handle_response(response)
  end

  private

  def filter_coin_ids(input_coin_ids)
    input_coin_ids & ALLOWED_COINS
  end

  def validate_values
    raise ArgumentError, "No valid Coin IDs provided" if @coin_ids.empty?
    raise ArgumentError, "Invalid currency" unless ALLOWED_CURRENCIES.include?(@vs_currency)
  end

  def build_request
    base_url = ENV["COIN_GECKO_API_URL"]
    api_key  = ENV["COIN_GECKO_API_KEY"]

    endpoint = "#{base_url}/simple/price?ids=#{merge_coin_ids}" \
               "&vs_currencies=#{@vs_currency}&precision=#{DEFAULT_PRECISION}"

    uri = URI(endpoint)

    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"
    request["x_cg_demo_api_key"] = api_key if api_key

    { uri: uri, request: request }
  end

  def make_request(params)
    uri     = params[:uri]
    request = params[:request]
    timeout = ENV["DEFAULT_TIMEOUT"].to_i

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.open_timeout = timeout
    http.read_timeout = timeout

    begin
      http.request(request)
    rescue SocketError, Timeout::Error, Errno::ECONNREFUSED => e
      # Handle network errors
      error_message = I18n.t("coingecko_errors.503", default: I18n.t("coingecko_errors.default"))
      ServiceResult.new(
        success: false,
        error_message: "#{error_message} (#{e.message})",
        error_code: 503,
        http_status: 503
      )
    end
  end

  def handle_response(response)
    # Handle non-HTTP response
    return response unless response.is_a?(Net::HTTPResponse)

    code = response.code.to_i

    if code == 200
      begin
        data = JSON.parse(response.body)
        return ServiceResult.new(success: true, data: data, http_status: 200)
      rescue JSON::ParserError => e
        # Handle invalid JSON response
        ServiceResult.new(
          success: false,
          error_message: "Invalid JSON response",
          error_code: 500,
          http_status: 500
        )
      end
    end

    # Handle coin gecko errors
    error_message = I18n.t("coingecko_errors.#{code}", default: I18n.t("coingecko_errors.default"))
    ServiceResult.new(
      success: false,
      error_message: error_message,
      error_code: code,
      http_status: code
    )
  end

  def merge_coin_ids
    @coin_ids.join(",")
  end
end
