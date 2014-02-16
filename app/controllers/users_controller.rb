require 'securerandom'
require 'json'

class UsersController < ApplicationController
  USER_REQUIRED = [:login,:password,:firstname,:surname,:dob]
  def new
    if !session[:access].nil?
      redirect_to "/user"
    end
    if request.post?
      if params[:password] != params[:password_confirm]
        flash.now[:alert] = I18n.t 'user_pass_error'
      else
        params[:login]=check_login_params(params)
        new_hash = {}
        new_hash[:uid] = SecureRandom.uuid
        new_hash[:user] = params[:login]
        new_hash[:locale] = params[:locale]
        new_hash[:pass] = params[:password]
        new_hash[:firstname] = params[:firstname]
        new_hash[:middlename] = params[:middlename]
        new_hash[:surname] = params[:surname]
        new_hash[:lastname] = params[:lastname]
        new_hash[:dob] = params[:dob]
        new_hash[:nested_info_example] = {:description => 'This is an example of extra metadata being included and encrypted within the user object.',:second_level=>{:more=>'This information was added at controller level within the "new" method.',:even_more=>'You can nest deeper and deeper without any problem.'}}
        req_check = true
        USER_REQUIRED.each do |req_key|
          req_check = false if (params[req_key].nil? || params[req_key] == "")
        end
        if req_check
          nu_user = false
          reg_error = ""
          begin
            nu_user = User.create(
              login: params[:login].downcase,
              user: JSON.generate(new_hash),
              active: 1
            )
          rescue ActiveRecord::RecordNotUnique => e
            reg_error = I18n.t 'user_exists_error'
          else
            reg_error = I18n.t 'user_reg_error'
          end
          if nu_user
            redirect_to "/login"
          else
            flash.now[:alert] = reg_error
          end
        else
          flash.now[:alert] = I18n.t 'user_info_reg_error'
        end
      end
    end
  end

  def login
    if !session[:access].nil?
      redirect_to "/user"
    end
    if request.post?
      params[:login] = check_login_params(params)
      if params[:login].nil?
        flash.now[:alert] = I18n.t 'user_login_error'
      else
        user_auth=User.authenticate(params[:login].downcase,params[:password])
        if user_auth[:result]
          session[:access] = user_auth[:user][:login]
          user_auth[:user].dcrypt_user
          user_hash=user_auth[:user].do_hash_user
          session[:gid] = Uindex.find_by_uid(user_hash[:uid])[:gid]
          puts "!#{session[:gid]}!"
          if !user_hash[:locale].nil?
            cookies['locale'] = user_hash[:locale]+'-'
          end
          cookies['uname'] = "#{user_hash[:firstname].capitalize} #{user_hash[:surname]}"
          redirect_to "/user"
        else
          flash.now[:alert] = user_auth[:error]
        end
      end
    end
  end
  
  def check_login_params(params)
    ((params[:login]=="" || params[:login].length<4) || (params[:password]=="" || params[:password].length<4)) ? nil : params[:login]
  end

  def edit
    #TODO: add ability to edit user info.
  end

  def destroy
    uidx = Uindex.find_by_gid(params[:gid])
    uidx = uidx.dcrypt_gid(GlobalKey.find_by_key('u541t')[:val])
    duser = User.find_by_id(uidx)
    duser[:active] = 0
    duser.save
    if (duser[:login] == session[:access])
      redirect_to "/logout"
    else
      render :json => true
    end
  end

  def show
    if session[:access].nil?
      redirect_to "/login"
    else
      user=User.find_by_login(session[:access])
      if !user
        redirect_to "/logout"
      else
        JSON.parse(user.to_json).each do |key,val|
          @user_enc = "#{@user_enc}<p class='break_word'>\"<b>#{key}</b>\" : \"#{val}\"</p>"
        end
        user.dcrypt_user
        @user_hash = recurse_paragraphing(JSON.parse(user.do_hash_user.to_json))
        
        @user = user.do_hash_user
      end
    end
  end
  
  def recurse_paragraphing(hash)
    ret = ""
    hash.each do |key,val|
      if (!val.is_a? Hash)
        ret = "#{ret}<div class='nestable break_word'>\"<b>#{key}</b>\" : \"#{val}\"</div>"
      else
        ret = "#{ret}<div class='nest_parent nestable break_word'>\"<b>#{key}</b>\" : #{recurse_paragraphing(val)}</div>"
      end
    end
    ret
  end
end