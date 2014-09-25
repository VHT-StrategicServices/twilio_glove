def log(text)
  File.open('log.txt', 'a') { |f| f.puts "#{Time.now}: #{text}" }
end

def log_exception(exception)
  log exception.message
  log exception.backtrace
end

def log_request where, request, status
  begin
    log "#{where} - #{request.ip} - #{request.request_method} #{request.path_info}?#{request.query_string} - #{params[:Body]} - #{status}"
  rescue Exception => err
    log_exception err
  end
end