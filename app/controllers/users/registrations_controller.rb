module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]

    def create
      build_resource(sign_up_params)
      
      # Basic date of birth validation
      unless valid_date_of_birth?
        flash.now[:alert] = 'Please provide a valid date of birth.'
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
        return
      end
      
      resource.age_group = AgeVerifier.new(resource).call
      
      if resource.age_group != :adult
        if parent_email_param.present?
          resource.save
          ConsentWorkflow.new(resource).request_consent(parent_email_param)
          set_flash_message! :notice, :signed_up_but_consent
          redirect_to root_path and return
        else
          flash.now[:alert] = 'Parental email required for users under 18.'
          clean_up_passwords resource
          set_minimum_password_length
          respond_with resource
          return
        end
      end
      resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :'signed_up_but_#{resource.inactive_message}'
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end

    protected

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [:date_of_birth])
    end

    private

    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation, :date_of_birth)
    end

    def parent_email_param
      params[:user][:parent_email]
    end
    
    def valid_date_of_birth?
      return false unless resource.date_of_birth
      
      # Check if date is in the future
      return false if resource.date_of_birth > Date.current
      
      # Check if date is too far in the past (e.g., more than 120 years ago)
      return false if resource.date_of_birth < 120.years.ago.to_date
      
      true
    end
  end
end 