---run this first
Use master

EXEC sp_configure 'show advanced options', '1';
RECONFIGURE
GO
EXEC sp_configure 'Database Mail XPs', 1;
RECONFIGURE
GO

--then run this

USE msdb

-- Creates the login account 
-- exampe login account is myadmin_login
CREATE LOGIN myadmin_login  
    WITH PASSWORD = 'your password';  
GO  

-- Creates a database user for the login account
CREATE USER myadmin_login FOR LOGIN myadmin_login;  
GO  


-- Create a Database Mail account 
-- example email is gmail
EXECUTE msdb.dbo.sysmail_add_account_sp  
    @account_name = 'account name',				-- ex -> myadmin_account  
    @description = 'desription',				-- ex -> Mail account for send email  
    @email_address = 'email address',			-- ex -> email_address@gmail.com  
    @replyto_address = 'reply email address',	-- comment if not needed  
    @display_name = 'display name',				-- the name that will be displayed when the email is sent
    @mailserver_name = 'mail server',			-- ex -> for gmail mail server is smtp.gmail.com
    @port = 000,								-- ex -> for gmail is 587
	@password = 'password gmail account',		-- Create app password in Google account https://support.google.com/accounts/answer/185833?hl=en 
	@username = 'email address',				-- equal to @email_address
	@enable_ssl = 1;							-- enable ssl


-- Create a Database Mail profile  
EXECUTE msdb.dbo.sysmail_add_profile_sp  
    @profile_name = 'profil name',				-- ex -> myadmin_profile
    @description = 'description';				-- ex -> Profile for send email.


-- Add the account to the profile  
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp  
    @profile_name = 'profil name',				-- profil name in sysmail_add_profile_sp
    @account_name = 'account name',				-- account name in  sysmail_add_account_sp
    @sequence_number = 1;


-- Grant the msdb user access to the Database Mail profile
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = 'profil name',				-- profil name in sysmail_add_profile_sp
    @principal_name = 'principal name',			-- name login account, the example above is myadmin_login
    @is_default = 1;



EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'profil name',				-- profil name in sysmail_add_profile_sp
    @recipients = 'email adress',				-- recipient email
    @body = 'this example send email ',			-- body text
    @subject = 'subject examples';				-- subject email


--with body html
DECLARE @body_content varchar(255);
SET @body_content = '<a href="#">example with send email with body html</a>';

EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'profil name',				-- profil name in sysmail_add_profile_sp  
    @recipients = 'email adress',				-- recipient email
    @body = @body_content, 
	@body_format = 'HTML',
    @subject = 'subject examples';				-- subject email

