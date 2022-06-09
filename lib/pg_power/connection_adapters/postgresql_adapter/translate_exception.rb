# Extend ActiveRecord::ConnectionAdapter::PostgreSQLAdapter logic
# to wrap more pg-specific errors into specific exception classes
module PgPower::ConnectionAdapters::PostgreSQLAdapter::TranslateException
  # # See http://www.postgresql.org/docs/9.1/static/errcodes-appendix.html
  INSUFFICIENT_PRIVILEGE = "42501"

  # Intercept insufficient privilege PG::Error and raise active_record wrapped database exception
  def translate_exception(exception, message)
    case exception.result.try(:error_field, PG:Result::PG_DIAG_SQLSTATE)
      when INSUFFICIENT_PRIVILEGE
        exc_message = exception.result.try(:error_field, PG::Result::PG_DIAG_MESSAGE_PRIMARY)
        exc_message ||= message
        ::ActiveRecord::InsufficientPrivilege.new(exc_message, exception)
      else
        super
    end
  end
end
