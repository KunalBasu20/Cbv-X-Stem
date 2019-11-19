class DocumentationsController < ApplicationController
  def index
    @documentations = Documentation.all
  end

  def new
    @documentation = Documentation.new
  end

  def create
      @documentation = Documentation.new(documentation_params)
      
      if @documentation.save
         
         redirect_to documentations_path, notice: "The document #{@documentation.patient} has been uploaded."
         @first_name, @last_name = @documentation.patient.split
         @cur_user = User.where(first_name: @first_name, last_name: @last_name).first
         @current_holder = @cur_user.user_holder
         @current_setting = @current_holder.user_setting
          if @current_setting.email_notification
            @cur_user_email = @cur_user.email
            @message = Message.new(:sender_name => @documentation.patient)
            @message.receiver_email = 'cbvxstem@gmail.com'
            MessageMailer.document_notification(@message).deliver
            if @cur_user_email != ""   
              @message.sender_email =  @cur_user_email
              MessageMailer.document_confirmation(@message).deliver
            end
          end           
      else
         render "new"
      end
  end

  def destroy
    @documentation = Documentation.find(params[:id])
    @documentation.destroy
    redirect_to documentations_path, notice: "The document #{@documentation.patient} has been deleted."
  end

  private
    def documentation_params
    params.require(:documentation).permit(:patient, :attachement)
  end

end
