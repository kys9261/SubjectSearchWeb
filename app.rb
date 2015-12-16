#!/usr/bin/env ruby
# encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'active_record'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'digest'
require 'mechanize'

ActiveRecord::Base.establish_connection(
  :adapter => "mysql2",
  :port => "3306",
  :host => "localhost",
  :username => "mysql_userName",
  :password => "mysql_password",
  :database => "mysql_dbName"
)

class Subject < ActiveRecord::Base
end

class Category < ActiveRecord::Base
end


$client = Mysql2::Client.new( :adapter => "mysql2",
   :port => "3306",
   :host => "localhost",
   :username => "mysql_userName",
   :password => "mysql_password",
   :database => "mysql_dbName")

$time = "2015년 6월 22일" 

get '/' do	
  	 @id = $client.query("select * from categories") 
	erb :index
end

get '/loadSub/:pids' do
    @id = params[:pids]
	@pid = $client.query("select * from categories where pid='#{@id}'")
	@sub = $client.query("select * from subject where pid='#{@id}'")
	puts @id
	erb :detail
end

get '/credit/:credits' do
    @credit = params[:credits]
	@list = $client.query("select * from subject where credits='#{@credit}'")
	erb :credit
end

post '/datetime' do
    @date = params[:date]
	@time = params[:time]

    case @time
	when 'a'
    	@dt = @date+@time
	when 'b'
		@dt = @date+@time
	when 'c'
		@dt = @date+@time
	when 'd'
		@dt = @date+@time
	else
		@dt = @date.to_i + @time.to_i
	end
	puts @dt
	@list = $client.query("select * from subject where datenum like '%#{@dt}%'")
	erb :datetime
end

get '/load' do
	$client.query("drop table subject")
	$client.query("create table subject (pid varchar(30), grade varchar(30), divider varchar(30), sbjnum varchar(30), divnum varchar(5), sbjtitle varchar(50), credits varchar(5), date varchar(50), professor varchar(30), location varchar(30), remark varchar(50), limitnum varchar(30), datenum varchar(50))")
	@id = $client.query("select pid from categories")
	erb :load
	redirect '/'
end

get '/email' do
	erb :email
end

post '/email_send' do

		  RestClient.post "mailgun api",
		  :from => "Sugang_20151 <#{params[:email]}>",
		  :to => "Destination <Dest_Email>",
		  :subject => params[:title],
		  :text => params[:content]

redirect '/'
end

post '/namesearch' do
	@name = params[:name]
	@list = $client.query("select * from subject where sbjtitle like '%#{@name}%'")
	erb :sbjname
end


#email regist testing
get '/email_reg' do
	erb :email_reg
end

post '/email_reg1' do
	@mail = params[:email]
	md5 = Digest::MD5.new
	md5.update @mail
	@encode = md5.hexdigest
	
	$client.query("insert into user value('#{@mail}', '#{@encode}','false')");
	
			  RestClient.post "mailgun api",
		  :from => "Sugang_20151 <test@123.co.kr>",
		  :to => "Destination <mail>",
	      :subject => params[:title],
		  :html =>"<html><body> <a href=\"http://210.119.32.15/user/reg?re=#{@encode}\">test</a></body></html>" 

end

get '/user/reg' do
	@encode1 = params[:re]
	$client.query("update user set flag='true' where encode like '#{@encode1}'");
end
