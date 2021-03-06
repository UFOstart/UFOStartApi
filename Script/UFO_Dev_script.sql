USE [master]
GO
/****** Object:  Database [UFO_Dev]    Script Date: 27.9.2013 12:57:45 ******/
CREATE DATABASE [UFO_Dev]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'UFO_Dev', FILENAME = N'C:\SQL\Data\UFO_Dev.mdf' , SIZE = 13568KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'UFO_Dev_log', FILENAME = N'C:\SQL\Log\UFO_Dev_log.ldf' , SIZE = 104000KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [UFO_Dev] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [UFO_Dev].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [UFO_Dev] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [UFO_Dev] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [UFO_Dev] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [UFO_Dev] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [UFO_Dev] SET ARITHABORT OFF 
GO
ALTER DATABASE [UFO_Dev] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [UFO_Dev] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [UFO_Dev] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [UFO_Dev] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [UFO_Dev] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [UFO_Dev] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [UFO_Dev] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [UFO_Dev] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [UFO_Dev] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [UFO_Dev] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [UFO_Dev] SET  DISABLE_BROKER 
GO
ALTER DATABASE [UFO_Dev] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [UFO_Dev] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [UFO_Dev] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [UFO_Dev] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [UFO_Dev] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [UFO_Dev] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [UFO_Dev] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [UFO_Dev] SET RECOVERY FULL 
GO
ALTER DATABASE [UFO_Dev] SET  MULTI_USER 
GO
ALTER DATABASE [UFO_Dev] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [UFO_Dev] SET DB_CHAINING OFF 
GO
ALTER DATABASE [UFO_Dev] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [UFO_Dev] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'UFO_Dev', N'ON'
GO
USE [UFO_Dev]
GO
/****** Object:  User [ufo_user]    Script Date: 27.9.2013 12:57:46 ******/
CREATE USER [ufo_user] FOR LOGIN [ufo_user] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  Schema [api]    Script Date: 27.9.2013 12:57:46 ******/
CREATE SCHEMA [api]
GO
/****** Object:  Schema [mess]    Script Date: 27.9.2013 12:57:46 ******/
CREATE SCHEMA [mess]
GO
/****** Object:  StoredProcedure [api].[admin_get_need]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [api].[admin_get_need]
@p xml,
@r xml output
as
begin try


declare @name nvarchar(255),
		@key nvarchar(255),
		@need_id int

		
	
select @name = @p.value('(Need/@name)[1]','nvarchar(255)'),
		@key = @p.value('(Need/@key)[1]','nvarchar(255)')

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if   @name is null and @key is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1) -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

select @need_id = id from need where [name] = @name or [key] = @key



	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					[dbo].[fn_get_need] (@need_id)
					for xml path ('Result')
				)


end try
begin  catch
	exec dbo.set_error @p , @r output
end catch

GO
/****** Object:  StoredProcedure [api].[admin_get_needs]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[admin_get_needs]
@p xml = null,
@r xml output
as
begin try

declare @needs xml


select @needs =  (
						select n.name as "@name",
						n.[key] as "@key",
						n.[description] as "@description",
						n.summary as "@summary",
						c.name as "@category",
						(
								select name as "@name",
										[description] as "@description"
								from need_tag nt
								join tag t
									on t.id = nt.tag_id
								where nt.need_id = n.id
								for xml path ('Tags'), type
							),
						(
								select s.name as "@name",
									s.url as "@url",
									s.logo as "@logo"
								from service_need sn
								join [service] s
									on s.id = sn.service_id
								where sn.need_id = n.id
								for xml path ('Services'), type
							)
						from need n							
						join category c
							on  c.id = n.category_id					
						for xml path ('Needs'), type		
			)



	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					@needs as "*"
					for xml path ('Result')
				)


end try
begin  catch
	exec dbo.set_error @p , @r output
end catch


GO
/****** Object:  StoredProcedure [api].[admin_get_template]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[admin_get_template]
@p xml,
@r xml output
as
begin try

declare @template xml

declare @key char(36),
		@name nvarchar(255),
		@template_id int

		
	
select @key = @p.value('(Template/@key)[1]','nvarchar(255)'),
	   @name = @p.value('(Template/@name)[1]','nvarchar(255)')

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if   @key is null and @name is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1) -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

select @template_id = id from template where [key] = @key or [name] = @name

	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					[dbo].[fn_get_template](@template_id)
					for xml path ('Result')
				)


end try
begin  catch
	exec dbo.set_error @p , @r output
end catch

GO
/****** Object:  StoredProcedure [api].[admin_get_templates]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[admin_get_templates]
@p xml = null,
@r xml output
as
begin try

declare @templates xml


select @templates =  (
					select name as "@name",
					[key] as "@key",
					[description] as "@description",
					picture as "@picture",
					active as "@active",
					logo as "@logo",
					(
						select n.name as "@name",
						n.[key] as "@key",
						n.[description] as "@description",
						n.summary as "@summary",
						c.name as "@category",
						(
								select name as "@name",
										[description] as "@description"
								from need_tag nt
								join tag t
									on t.id = nt.tag_id
								where nt.need_id = n.id
								for xml path ('Tags'), type
							)
						from template_need tn
						join need n
							on n.id = tn.need_id
						join category c
							on  c.id = n.category_id
						where tn.template_id = t.id
						for xml path ('Need'), type
					)
					from template t
					for xml path ('Templates'), type
			)



	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					@templates
					for xml path ('Result')
				)


end try
begin  catch
	exec dbo.set_error @p , @r output
end catch

GO
/****** Object:  StoredProcedure [api].[admin_need_create]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[admin_need_create]
@p xml,
@r xml output
as
begin try

	declare @name nvarchar(255),
			@description nvarchar(max),
			@category_id int,
			@category nvarchar(255),
			@dbMessage varchar(255),
			@summary nvarchar(max),
			@need_id int
	
	declare @tags table (name nvarchar(255))
	declare @services table (name nvarchar(255))

	select @name = @p.value('(Need/@name)[1]', 'nvarchar(255)'),
		 @description = @p.value('(Need/@description)[1]', 'nvarchar(max)'),
		 @category = @p.value('(Need/@category)[1]', 'nvarchar(255)'),
		 @summary = @p.value('(Need/@summary)[1]', 'nvarchar(max)')
	
-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @name is null  or @category is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	


	insert @tags 
	(name)
	select 
	rows.n.value('(@name)[1]', 'nvarchar(255)')
	from @p.nodes('Need/Tags')rows(n)

	insert @services 
	(name)
	select 
	rows.n.value('(@name)[1]', 'nvarchar(255)')
	from @p.nodes('Need/Services')rows(n)

	select @category_id = id from category where name = @category
	
	if exists (select 1 from need where name = @name)
	begin
		set @dbMessage = 'Need_Already_Exists'
	end
	else
	begin
		insert need
		(name, [description], category_id, [key], [summary])
		select @name, @description, @category_id, dbo.fn_create_key(@name),@summary
		set @need_id = scope_identity()

		insert tag
		(name)
		select qt.name
		from @tags qt
		left join tag t 
			on qt.name = t.name 
		where t.id is null
		and qt.name is not null

		insert need_tag(need_id, tag_id)
		select @need_id, t.id
		from @tags qt
		join tag t
			on t.name=qt.name
	
		insert service_need
		(service_id, need_id)
		select s.id, @need_id
		from @services qs
		join [service] s 
			on s.name = qs.name
		
	end
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@dbMessage as "@dbMessage"
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch

GO
/****** Object:  StoredProcedure [api].[admin_need_edit]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[admin_need_edit]
@p xml,
@r xml output
as
begin try

	declare @name nvarchar(255),
			@description nvarchar(max),
			@category_id int,
			@category nvarchar(255),
			@dbMessage varchar(255),
			@need_id int,
			@key nvarchar(255),
			@summary nvarchar(max)
	
	declare @tags table (name nvarchar(255))
	declare @services table (name nvarchar(255))

	select @name = @p.value('(Need/@name)[1]', 'nvarchar(255)'),
			@description = @p.value('(Need/@description)[1]', 'nvarchar(max)'),
			@category = @p.value('(Need/@category)[1]', 'nvarchar(255)'),
			@key = @p.value('(Need/@key)[1]', 'nvarchar(255)'),
			@summary =  @p.value('(Need/@summary)[1]', 'nvarchar(max)')
		
-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @name is null  or @category is null or @key is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	
	
	select @need_id = id from need where [key] = @key

	insert @tags 
	(name)
	select 
	rows.n.value('(@name)[1]', 'nvarchar(255)')
	from @p.nodes('Need/Tags')rows(n)

	insert @services 
	(name)
	select 
	rows.n.value('(@name)[1]', 'nvarchar(255)')
	from @p.nodes('Need/Services')rows(n)

	select @category_id = id from category where name = @category
	
	if (@need_id is null)
	begin
		set @dbMessage = 'No_Such_Need'
	end
	else
	begin
		update need
		set name = @name, 
		[description] = @description, 
		category_id = @category_id,
		summary=@summary
		where id = @need_id

		delete from need_Tag
		where need_id=@need_id 

		delete from service_need
		where need_id = @need_id

		insert tag
		(name)
		select qt.name
		from @tags qt
		left join tag t 
			on qt.name = t.name 
		where t.id is null
		and qt.name is not null

		insert need_tag(need_id, tag_id)
		select @need_id, t.id
		from @tags qt
		join tag t
			on t.name=qt.name
	
		insert service_need
		(service_id, need_id)
		select s.id, @need_id
		from @services qs
		join [service] s 
			on s.name = qs.name
					
	end
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@dbMessage as "@dbMessage"
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch

GO
/****** Object:  StoredProcedure [api].[admin_service_create]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[admin_service_create]
@p xml,
@r xml output
as
begin try

	declare @name nvarchar(255),
			@url nvarchar(255),
			@logo nvarchar(255),
			@dbMessage nvarchar(255)
			
			
  select @name = @p.value('(Service/@name)[1]', 'nvarchar(255)'),
		 @url = @p.value('(Service/@url)[1]', 'nvarchar(255)'),
		 @logo = @p.value('(Service/@logo)[1]', 'nvarchar(255)')
		
-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @name is null or @url is null or @logo is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	


	if  exists ( select 1 from [service] where name = @name)
	begin
		set @dbMessage = 'Service_Already_Exists'
	end
	else
	begin
		insert service
		(name, url, logo)
		select @name, @url, @logo
	end

	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@dbMessage as "@dbMessage"
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch
GO
/****** Object:  StoredProcedure [api].[admin_service_edit]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [api].[admin_service_edit]
@p xml,
@r xml output
as
begin try

	declare @name nvarchar(255),
			@url nvarchar(255),
			@logo nvarchar(255),
			@dbMessage nvarchar(255),
			@service_id int
			
			
  select @name = @p.value('(Service/@name)[1]', 'nvarchar(255)'),
		 @url = @p.value('(Service/@url)[1]', 'nvarchar(255)'),
		 @logo = @p.value('(Service/@logo)[1]', 'nvarchar(255)')
		
-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @name is null or @url is null or @logo is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	
	
	select @service_id = id from [service] where name = @name

	if  (@service_id is null)
	begin
		set @dbMessage = 'No_Such_Service'
	end
	else
	begin
		update service
		set name = @name, 
			url = @url, 
			logo = @logo
		where id = @service_id
	end

	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@dbMessage as "@dbMessage"
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch
GO
/****** Object:  StoredProcedure [api].[admin_service_get]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [api].[admin_service_get]
@p xml = null,
@r xml output
as
begin try

declare @name nvarchar(255),
		@service_id int

		
	
select @name = @p.value('(Service/@name)[1]','nvarchar(255)')

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if   @name is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1) -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

select @service_id = id from service where [name] = @name




	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					[dbo].[fn_get_service](@service_id)
					for xml path ('Result')
				)


end try
begin  catch
	exec dbo.set_error @p , @r output
end catch

GO
/****** Object:  StoredProcedure [api].[admin_services_get]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [api].[admin_services_get]
@p xml = null,
@r xml output
as
begin try

declare @services xml


select @services =  (
					select name as "@name",
						   url as "@url",
						   logo as "@logo"
					from [service]
					for xml path ('Services'), type
			)



	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					@services
					for xml path ('Result')
				)


end try
begin  catch
	exec dbo.set_error @p , @r output
end catch

GO
/****** Object:  StoredProcedure [api].[admin_static_get]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[admin_static_get]
@p xml = null,
@r xml output
as
begin try

declare @static xml

	set @static=(
		select [static] as "*"
		from content
	)

	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@static
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch



GO
/****** Object:  StoredProcedure [api].[admin_static_set]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[admin_static_set]
@p xml,
@r xml output
as
begin try

	update [content]
	set [static] = @p
	where id = 1

	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName"
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch



GO
/****** Object:  StoredProcedure [api].[admin_template_create]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[admin_template_create]
@p xml,
@r xml output
as
begin try

	declare @name nvarchar(255),
			@description nvarchar(max),
			@picture nvarchar(255),
			@dbMessage varchar(255),
			@template_id int,
			@active bit,
			@logo nvarchar(255)
			
	
	declare @needs table (name nvarchar(255))

	select @name = @p.value('(Template/@name)[1]', 'nvarchar(255)'),
		 @description = @p.value('(Template/@description)[1]', 'nvarchar(max)'),
		 @picture = @p.value('(Template/@picture)[1]', 'nvarchar(255)'),
		 @active = @p.value('(Template/@active)[1]', 'bit'),
		@logo =  @p.value('(Template/@logo)[1]', 'nvarchar(255)')
-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @name is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	


	insert @needs 
	(name)
	select 
	rows.n.value('(@name)[1]', 'nvarchar(255)')
	from @p.nodes('Template/Need')rows(n)

	if exists (select 1 from template where name = @name)
	begin
		set @dbMessage = 'Template_Already_Exists'
	end
	else
	begin
		insert template
		(name, [key], [description], picture, active, logo)
		select @name, dbo.fn_create_key(@name), @description, @picture, @active,@logo
		set @template_id = scope_identity()

		insert template_need
		(template_id, need_id)
		select @template_id, n.id
		from need n
		join @needs qn
			on n.name= qn.name

	end

	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@dbMessage as "@dbMessage"
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch



GO
/****** Object:  StoredProcedure [api].[admin_template_edit]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[admin_template_edit]
@p xml,
@r xml output
as
begin try

	declare @name nvarchar(255),
			@key nvarchar(255),
			@description nvarchar(max),
			@picture nvarchar(255),
			@dbMessage varchar(255),
			@template_id int,
			@active bit,
			@logo nvarchar(255)
			
	
	declare @needs table (name nvarchar(255))

  select @name = @p.value('(Template/@name)[1]', 'nvarchar(255)'),
		 @description = @p.value('(Template/@description)[1]', 'nvarchar(max)'),
		 @picture = @p.value('(Template/@picture)[1]', 'nvarchar(255)'),
		 @active = @p.value('(Template/@active)[1]', 'bit'),
		 @key = @p.value('(Template/@key)[1]', 'nvarchar(255)'),
		 @logo = @p.value('(Template/@logo)[1]', 'nvarchar(255)')
	
-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @key is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	

	select @template_id=id from template where [key] = @key

	insert @needs 
	(name)
	select 
	rows.n.value('(@name)[1]', 'nvarchar(255)')
	from @p.nodes('Template/Need')rows(n)

	if  (@template_id is null)
	begin
		set @dbMessage = 'No_Such_Template'
	end
	else
	begin
		update template
		set 
		name = @name, 
		[description]=@description, 
		picture = @picture, 
		active = @active,
		logo = @logo
		where id = @template_id

		delete from template_need
		where template_id = @template_id

		insert template_need
		(template_id, need_id)
		select @template_id, n.id
		from need n
		join @needs qn
			on n.name= qn.name
	end

	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@dbMessage as "@dbMessage"
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [api].[company_add_angel_list]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE  proc [api].[company_add_angel_list]
	@p xml,
	@r xml output
	as
	begin try
	declare @slug nvarchar(255),
			@company xml,
			@angelListId nvarchar(255),
			@angelListToken nvarchar(255),
			@company_id int,
			@name nvarchar(255),
			@url nvarchar(255),
			@logo nvarchar(255),
			@description nvarchar(max),
			@tag_string nvarchar(4000)


	select @slug = @p.value('(Company/@slug)[1]', 'nvarchar(255)'),
			@angelListId = @p.value('(Company/@angelListId)[1]', 'nvarchar(255)'),
			@angelListToken = @p.value('(Company/@angelListToken)[1]', 'nvarchar(255)'),
			@url = @p.value('(Company/@url)[1]', 'nvarchar(255)'),
			@name = @p.value('(Company/@name)[1]', 'nvarchar(255)'),
			@logo = @p.value('(Company/@logo)[1]', 'nvarchar(255)'),
			@description = @p.value('(Company/@description)[1]', 'nvarchar(max)'),
			@tag_string = @p.value('(Company/@tagString)[1]', 'nvarchar(4000)')

	---------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	IF @slug is null or @angelListId is null or @angelListToken is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	update company 
	set angel_list_id = @angelListId,
	angel_list_token = @angelListToken,
	@company_id = id,
	logo = @logo,
	url = @url,
	name = @name,
	tag_string = @tag_string,
	description = @description
	where slug = @slug

		select @r = (
				select 0 as "@status", 
				object_name(@@procid) as "@procName",
				dbo.fn_get_company(@company_id)
				for xml path ('Result')
			)


	end try
	begin catch
		exec set_error @p , @r output
	end catch



GO
/****** Object:  StoredProcedure [api].[company_add_template]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [api].[company_add_template]
@p xml,
@r xml output
as
begin try

declare @template nvarchar(255),
		@token char(36),
		@company_id int,
		@template_id int

select @template = @p.value('(Company/Template/@name)[1]', 'nvarchar(255)'),
		@token = @p.value('(Company/@token)[1]' ,'char(36)')

-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	IF @template is null or @token is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------


select @company_id = (
						select top 1 company_id 
						from user_company uc
						join company c
							on c.id = uc.[company_id]
						where c.token = @token
					)

select @template_id = id from template where name = @template

insert company_template
(company_id, template_id)
select @company_id,  @template_id


select @r = (
				select 0 as "@status", 
				object_name(@@procid) as "@procName"
				for xml path ('Result')
			)

end try
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [api].[company_create]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[company_create]
@p xml,
@r xml output
as
begin try 


declare @token char(36),
		@user_id int,
		@name nvarchar(255),
		@description nvarchar(max),
		@dbMessage varchar(255),
		@template nvarchar(255),
		@template_id int,
		@status_id int,
		@new_round int,
		@angelListId nvarchar(255),
		@angelListToken nvarchar(255),
		@logo nvarchar(255),
		@pitch nvarchar(4000),
		@video nvarchar(255),
		@slideshare nvarchar(1014),
		@currency nvarchar(25)


select @token = @p.value('(User/@token)[1]', 'char(36)'),
		@name = @p.value('(User/Company/@name)[1]', 'nvarchar(255)'),
		@description = @p.value('(User/Company/@description)[1]', 'nvarchar(max)'),
		@template = @p.value('(User/Company/Template/@key)[1]', 'nvarchar(255)'),
		@angelListId = @p.value('(User/Company/@angelListId)[1]', 'nvarchar(255)'),
		@angelListToken = @p.value('(User/Company/@angelListToken)[1]', 'nvarchar(255)'),
		@logo = @p.value('(User/Company/@logo)[1]', 'nvarchar(255)'),
		@pitch = @p.value('(User/Company/@pitch)[1]', 'nvarchar(255)'),
		@video = @p.value('(User/Company/@video)[1]', 'nvarchar(255)'),
		@slideshare = @p.value('(User/Company/@slideShare)[1]', 'nvarchar(255)'),
		@currency =  @p.value('(User/Company/@currency)[1]', 'nvarchar(25)')

-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

select @user_id = id from [user] where token = @token 
select @template_id = id from template where [key] = @template

if exists(select 1 from company where slug = dbo.fn_create_slug(@name))
set @dbMessage = 'Company_Already_Exists'
else
begin

declare @company_id int,
		@newdid char(36) 

	set @newdid = (select guid from v_newid)

-------------
--CREATE COMPANY
--------------


insert company
(token, name, description, slug, angel_list_id, angel_list_token,logo, pitch, video, slide_share, currency_id)
select @newdid, @name , @description, isnull(dbo.fn_create_slug(@name), @newdid), @angelListId,	@angelListToken, @logo, @pitch, @video, @slideshare, c.id
from currency c
where name=@currency
set @company_id  = scope_identity()


insert user_company
([user_id], company_id)
select @user_id, @company_id


declare @picture table (url nvarchar(255))
insert @picture
(url)
select 
rows.n.value('(@url)[1]', 'nvarchar(255)')
from @p.nodes('User/Company/Pictures')rows(n) 


insert company_picture 
(url, company_id)
select  url, @company_id
from @picture


-------------
--CREATE ROUND
--------------

update [round]
set finished = getutcdate()
where finished is null
and company_id  = @company_id

insert [round] 
(company_id, start, created, token, template_id)
select @company_id, getutcdate(),  getutcdate(), newid(), @template_id
set @new_round = scope_identity()

-------------
--ADD NEEDS--
--------------

select @status_id = id from [status] where name = 'PENDING'

insert [dbo].[round_need]
(round_id, need_id,status_id, token, name, picture, slug)
select @new_round, need_id, @status_id, newid(), n.name, n.picture, [dbo].[fn_create_slug]( n.name)
from template_need tn
join need n
	on n.id = tn.need_id
where template_id = @template_id


insert round_need_tag
(round_need_id, tag_id)
select distinct id , nt.tag_id
from round_need rn
join need_tag nt
	on nt.need_id = rn.need_id
where rn.round_id = @new_round


insert activity 
(item , round_id)
select [dbo].[fn_activ_company_setup](@company_id), @new_round

end

select @r = (
				select 0 as "@status", 
				object_name(@@procid) as "@procName", 
				@dbMessage as"@dbMessage",
				dbo.fn_get_user_base(@user_id) as "*"
				for xml path ('Result')
			)
				

end try
begin catch 
	exec dbo.set_error @p, @r output
end catch 

GO
/****** Object:  StoredProcedure [api].[company_edit]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[company_edit]
@p xml,
@r xml output
as
begin try 


declare @token char(36),
		@user_id int,
		@name nvarchar(255),
		@description nvarchar(max),
		@dbMessage varchar(255),
		@template nvarchar(255),
		@template_id int,
		@status_id int,
		@new_round int,
		@angelListId nvarchar(255),
		@angelListToken nvarchar(255),
		@logo nvarchar(255),
		@pitch nvarchar(4000),
		@video nvarchar(255),
		@slideshare nvarchar(1014),
		@company_id int,
		@currency nvarchar(25),
		@currency_id int


declare @picture table (url nvarchar(255))

select @token = @p.value('(Company/@token)[1]', 'char(36)'),
		@name = @p.value('(Company/@name)[1]', 'nvarchar(255)'),
		@description = @p.value('(Company/@description)[1]', 'nvarchar(max)'),
		@template = @p.value('(Company/Template/@key)[1]', 'nvarchar(255)'),
		@angelListId = @p.value('(Company/@angelListId)[1]', 'nvarchar(255)'),
		@angelListToken = @p.value('(Company/@angelListToken)[1]', 'nvarchar(255)'),
		@logo = @p.value('(Company/@logo)[1]', 'nvarchar(255)'),
		@pitch = @p.value('(Company/@pitch)[1]', 'nvarchar(255)'),
		@video = @p.value('(Company/@video)[1]', 'nvarchar(255)'),
		@slideshare = @p.value('(Company/@slideShare)[1]', 'nvarchar(255)'),
		@currency =  @p.value('(Company/@currency)[1]', 'nvarchar(25)')
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------


insert @picture
(url)
select 
rows.n.value('(@url)[1]', 'nvarchar(255)')
from @p.nodes('Company/Pictures')rows(n) 


select @currency_id = id from currency where name = @currency

update company 
set name = @name ,
description = @description,
angel_list_id = @angelListId,
angel_list_token = @angelListToken,
logo = @logo,
pitch = @pitch,
video = @video,
slide_share = @slideshare,
@company_id = id,
currency_id = @currency_id
where token = @token 


delete from company_picture
where company_id  = @company_id 


insert company_picture 
(url, company_id)
select url, @company_id
from @picture




select @r = (
				select 0 as "@status", 
				object_name(@@procid) as "@procName", 
				@dbMessage as"@dbMessage",
				[dbo].[fn_get_company](@company_id) as "*"
				for xml path ('Result')
			)
				

end try
begin catch 
	exec dbo.set_error @p, @r output
end catch 

GO
/****** Object:  StoredProcedure [api].[company_get]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE  proc [api].[company_get]
	@p xml,
	@r xml output
	as
	begin try
	declare @slug nvarchar(255),
			@company xml

	select @slug = @p.value('(Company/@slug)[1]', 'nvarchar(255)')
	-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	IF @slug is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	select @company = [dbo].[fn_get_company](id)
	from company
	where slug = @slug

		select @r = (
				select 0 as "@status", 
				object_name(@@procid) as "@procName",
				@company
				for xml path ('Result')
			)


	end try
	begin catch
		exec set_error @p , @r output
	end catch


GO
/****** Object:  StoredProcedure [api].[company_get_from_round]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE  proc [api].[company_get_from_round]
	@p xml,
	@r xml output
	as
	begin try
	declare @token char(36),
			@company xml,
			@company_id int

	select @token  = @p.value('(Round/@token)[1]', 'char(36)')
	-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	IF @token is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	select @company_id = max(company_id) from round where token = @token 

	select @company = [dbo].[fn_get_company](@company_id)

		select @r = (
				select 0 as "@status", 
				object_name(@@procid) as "@procName",
				@company
				for xml path ('Result')
			)


	end try
	begin catch
		exec set_error @p , @r output
	end catch



GO
/****** Object:  StoredProcedure [api].[company_get_round]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[company_get_round]
@p xml,
@r xml output
as
begin try

	declare @company_id int,
			@token char(36),
			@round xml

			
	select @token = @p.value('(Round/@token)[1]', 'char(36)')

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	



select @round = dbo.fn_get_round(id) from [round] where token = @token 


			
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@round
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [api].[company_invite]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [api].[company_invite]
@p xml,
@r xml output
as
begin try 

	declare @email nvarchar(255),
			@invitorToken  char(36),
			@companySlug char(36),
			@name nvarchar(255),
			@company_id int,
			@invitor_id int ,
			@inviteToken char(36),
			@role nvarchar(255),
			@role_id int,
			@invite_id int,
			@round_id int,
			@user_token char(36)

	select @email = @p.value('(Invite/@email)[1]', 'nvarchar(255)'),
	@invitorToken = @p.value('(Invite/@invitorToken)[1]', 'nvarchar(255)'),
	@companySlug = @p.value('(Invite/@companySlug)[1]', 'nvarchar(255)'),
	@name = @p.value('(Invite/@name)[1]', 'nvarchar(255)'),
	@inviteToken = @p.value('(Invite/@inviteToken)[1]', 'char(36)'),
	@role = @p.value('(Invite/@role)[1]', 'nvarchar(255)'),
	@user_token = @p.value('(Invite/@userToken)[1]', 'char(36)')

-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @email is null or @invitorToken is null or @companySlug is null or @role is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	
	select @role_id = id from [role] where name = @role
	select @company_id  = id from company where slug = @companySlug
	select @invitor_id = id from [user] where token = @invitorToken
	select @round_id = max(id) from round where company_id = @company_id

	if @email not in (select email from invite where company_id = @company_id and role_id = @role_id)
	begin
		insert invite
		(token, email, name, invitor_id, company_id, role_id, user_token)
		select @inviteToken, @email, @name, @invitor_id, @company_id, @role_id, @user_token
		set @invite_id  = scope_identity()
	

	if @role = 'MENTOR'
	insert activity
	(item, round_id)
	select [dbo].[fn_activ_new_mentor_invite](@invite_id), @round_id
	else 
	insert activity
	(item, round_id)
	select [dbo].[fn_activ_new_team_member_invite](@invite_id), @round_id
	end

	select @r = (
		select 0 as "@status", 
		object_name(@@procid) as "@procName"
		for xml path ('Result')
	)	
	


end try
begin catch
	exec dbo.set_error @p, @r output
end catch
GO
/****** Object:  StoredProcedure [api].[company_needs_create]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[company_needs_create]
@p xml,
@r xml output
as
begin try

	declare @round xml,
			@token char(36),
			@round_id int

	
	declare @needs table (id int, name nvarchar(255))
	
	select @token = @p.value('(Round/@token)[1]', 'char(36)')

	insert @needs
	(id , name) 
	select 
	rows.n.value('(@id)[1]', 'int'),
	rows.n.value('(@name)[1]', 'nvarchar(255)')
	from @p.nodes('Round/Needs')rows(n)

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end

	if not exists (select 1 from @needs)
		begin 
		raiserror	(N'no needs passed in',
					16, -- severity.
					1); -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	

	select @round_id = id from [round] where token = @token 

	insert [dbo].[round_need]
	(round_id, need_id, created)
	select distinct @round_id, n.id, getutcdate()
	from @needs t
	join need n
		on t.name = n.name 

select @round = dbo.fn_get_round(@round_id)

	
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@round
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch



GO
/****** Object:  StoredProcedure [api].[company_product_offer_delete]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [api].[company_product_offer_delete]
@p xml,
@r xml output
as 
begin try 

	declare @token char(36),
			@product_id int
	
	select	@token = @p.value('(Offer/@token)[1]', 'char(36)')

-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	
	delete offer 
	where token = @token

	
	select @r = (
				select 0 as "@status", 
				object_name(@@procid) as "@procName"
				for xml path('Result')
				)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch

GO
/****** Object:  StoredProcedure [api].[company_product_offers]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[company_product_offers]
@p xml,
@r xml output
as 
begin try 

	declare @token char(36),
			@product_id int
	
	select	@token = @p.value('(Round/Product/@token)[1]', 'char(36)')

	declare @offers table (description nvarchar(400), stock int, price int, name nvarchar(255) )

	insert @offers
	(description, stock, price, name) 
	select 
	rows.n.value('(@description)[1]', 'nvarchar(255)'),
	rows.n.value('(@stock)[1]', 'nvarchar(255)'),
	rows.n.value('(@price)[1]', 'nvarchar(255)'),
	rows.n.value('(@name)[1]', 'nvarchar(255)')
	from @p.nodes('Round/Product/Offers')rows(n)

	select @product_id = id from product where token = @token 

	select * from @offers
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

	if not exists (select 1 from @offers)
						
		begin 
		raiserror	('no offers',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	
	delete offer 
	where product_id = @product_id
	and id not in (select offer_id from pledge)


	insert offer
	(description, product_id, stock , price, name )
	select description, @product_id, stock, price, name 
	from @offers
	where description not in (select isnull(description, newid()) from offer where product_id = @product_id)


	select @r = (
				select 0 as "@status", 
				object_name(@@procid) as "@procName",
				dbo.fn_get_round(@product_id) as "*"
				for xml path('Result')
				)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch

GO
/****** Object:  StoredProcedure [api].[company_product_set]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[company_product_set]
@p xml,
@r xml output
as 
begin try 

	declare @name nvarchar(255),
			@description nvarchar(max),
			@round char(36),
			@product char(36),
			@round_id int,
			@picture nvarchar(255),
			@token char(36),
			@video varchar(255),
			@product_id int
	
	
	select	@name = @p.value('(Round/Product/@name)[1]', 'nvarchar(255)'),
			@description = @p.value('(Round/Product/@description)[1]', 'nvarchar(max)'),
			@token = @p.value('(Round/Product/@token)[1]', 'char(36)'),
			@round = @p.value('(Round/@token)[1]', 'char(36)'),
			@picture = @p.value('(Round/Product/@picture)[1]', 'nvarchar(255)'),
			@video = @p.value('(Round/Product/@video)[1]', 'nvarchar(255)')

declare @picture_tab table (url nvarchar(255))
	
insert @picture_tab
(url)
select distinct
rows.n.value('(@url)[1]', 'nvarchar(255)')
from @p.nodes('Round/Product/Pictures')rows(n) 
	

	select @round_id = id from [round] where token = @round 

	if not exists (select 1 from product where id = @round_id)
	begin 

		insert product 
		(id, name, [description], created, picture, token, video)
		select @round_id, @name, @description, getutcdate(), @picture, newid(), @video

	end
	else 
	begin 
	
		update p 
		set name = @name,
			[description] = @description ,
			picture = @picture, 
			video = @video
		from product p
		where id = @round_id

	end

	delete from product_picture where product_id = @round_id
	insert product_picture
	(product_id, url)
	select distinct @round_id, url
	from @picture_tab



	
	select @r = (
				select 0 as "@status", 
				object_name(@@procid) as "@procName",
				dbo.fn_get_round(@round_id) as "*"
				for xml path('Result')
				)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [api].[company_round_create]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[company_round_create]
@p xml,
@r xml output
as
begin try

	declare @company_id int,
			@slug char(36),
			@new_round int,
			@round xml

	select @slug = @p.value('(Company/@slug)[1]', 'char(36)')

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @slug is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end


-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	

	select @company_id = id from company where slug = @slug 
		
	update [round]
	set finished = getutcdate()
	where finished is null
	and company_id  = @company_id

	insert [round] 
	(company_id, start, created, token)
	select @company_id, getutcdate(),  getutcdate(), newid()
	set @new_round = scope_identity()

	select  @round = dbo.fn_get_round(@new_round)

			
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@round
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch



GO
/****** Object:  StoredProcedure [api].[company_update]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[company_update]
@p xml,
@r xml output
as
begin try 


declare @token char(36),
		@text nvarchar(max),
		@user_token char(36),
		@user_id int,
		@company_id int  

select	@token = @p.value('(Company/@token)[1]', 'char(36)'),
		@text = @p.value('(Company/Update/@text)[1]', 'nvarchar(max)'),
		@user_token = @p.value('(Company/Update/@userToken)[1]', 'char(36)')
		
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null 
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

select @user_id = id from [user] where token = @user_token  
select @company_id = id from company where token = @token 


insert dbo.company_update 
(company_id, value, [user_id])
select @company_id, @text, @user_id



select @r = (
				select 0 as "@status", 
				object_name(@@procid) as "@procName", 
				[dbo].[fn_get_company](@company_id) as "*"
				for xml path ('Result')
			)
				

end try
begin catch 
	exec dbo.set_error @p, @r output
end catch 

GO
/****** Object:  StoredProcedure [api].[config]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[config]
@p xml = null,
@r xml output
as 
begin try
declare @config xml

set @config = 
			(
				select 
				(
					select c.name as "@name"
					from category c
 					for xml path ('Categories'), type
				),
				(
					select r.name as "@name"
					from [role] r
 					for xml path ('Roles'), type
				),
				(
					select c.name as "@name"
					from currency c 
					for xml path ('Currency'), type
				
				)
					
				for xml path ('Config')
			)
	select @r = (
			select 0 as "@status", 
			object_name(@@procid) as "@procName",
			@config as "*"
			for xml path ('Result')
		)	
	
end try
begin catch
	exec set_error @p, @r output
end catch





GO
/****** Object:  StoredProcedure [api].[get_slug_type]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [api].[get_slug_type]
@p xml,
@r xml output
as
begin try


declare @slug nvarchar(255),
		@xml xml
		
select @slug = @p.value('(User/@slug)[1]','nvarchar(255)')
	  
-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if   @slug is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1) -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------


	select @xml = 
				(
				select [type] as "@type"
				from dbo.v_slug
				where slug = @slug
				for xml path ('Slug')
				)
	
	
	
	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					@xml
					for xml path ('Result')
				)


end try
begin  catch
	exec dbo.set_error @p , @r output
end catch

GO
/****** Object:  StoredProcedure [api].[global_config]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [api].[global_config]
@p xml = null,
@r xml output
as
begin try

declare @setting xml,
		@global xml
		
		
set @setting = (
				select [key] as "@key",
						value as "@value"
				from setting
				for xml path ('Setting'),type
				)

				
set @global = (
				select @setting as "*"
				for xml path ('Global'), type
				)


select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@global as "*"
	for xml path('Result')
	)


end try
begin catch
	exec dbo.set_error @p, @r output
end catch



GO
/****** Object:  StoredProcedure [api].[invite_accept]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[invite_accept]
@p xml,
@r xml output
as
begin try

	declare @inviteToken char(36),
			@userToken char(36),
			@user_id int,
			@company_id int,
			@role_id int,
			@user_company_id int,
			@round_id int,
			@role varchar(255)


	select @inviteToken = @p.value('(Invite/@inviteToken)[1]', 'char(36)'),
	@userToken = @p.value('(Invite/@userToken)[1]', 'char(36)')

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @inviteToken is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end


-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	

	




	select @user_id = id from [user] where @userToken = token
	
	update invite 
	set confirmed = 1,
	@company_id = company_id,
	@role_id = role_id
	where token = @inviteToken
	
	if not exists(select 1 from user_company where [user_id] = @user_id and company_id = @company_id)

	insert user_company
	([user_id], company_id, role_id)
	select @user_id , @company_id, @role_id
	set @user_company_id = scope_identity()
	
	select @user_company_id = id 
	from user_company 
	where [user_id] = @user_id
	and company_id = @company_id



	select @round_id = r.id 
	from round r
	join company c
		on c.id = r.company_id
	join user_company uc
		on uc.company_id = c.id
	where uc.id = @user_company_id

	select @user_id, @company_id

	select @role  = name from role where id = @role_id


	if @role = 'MENTOR'
		insert activity
		(item, round_id)
		select [dbo].[fn_activ_new_mentor](@user_company_id), @round_id
	else 
		insert activity
		(item, round_id)
		select [dbo].[fn_activ_new_team_member](@user_company_id), @round_id
			
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName"
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch



GO
/****** Object:  StoredProcedure [api].[invite_get]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[invite_get]
@p xml,
@r xml output
as
begin try

	declare @inviteToken char(36),
			@invite xml,
			@dbMessage nvarchar(255)

	select @inviteToken = @p.value('(Invite/@inviteToken)[1]', 'char(36)')

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @inviteToken is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end


-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	

if not exists (select 1 from invite where token = @inviteToken)
	set @dbMessage = 'Invalid_Token'

set @invite = 
			(
			select u.name as "@invitorName",
					c.slug as "@companySlug",
					c.name as "@companyName",
					i.name as "@name",
					i.token as "@inviteToken",
					r.name as "@role"
			from invite i
			join [role] r
				on r.id = i.role_id
			join [user]	u
				on u.id  = i.invitor_id
			join company c
				on c.id = i.company_id 
			where i.token  = @inviteToken
			for xml path ('Invite'), type
			)

			
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@dbMessage as "@dbMessage",
	@invite
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [api].[need_application]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[need_application]
@p xml,
@r xml output
as
begin try 


declare @token char(36), 
		@user char(36), 
		@message nvarchar(max),
		@round_need_id int,
		@round_id int,
		@user_id int,
		@application_id int


select	@token = @p.value('(Need/@token)[1]', 'char(36)'),
		@user = @p.value('(Need/Application/User/@token)[1]', 'char(36)'),
		@message = @p.value('(Need/Application/@message)[1]', 'nvarchar(max)')


-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null or @user is null or @message is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------


	select @round_need_id = id,
	@round_id = round_id 
	from round_need where token = @token 
	select @user_id = id from [user] where token = @user 

	insert [application] 
	([user_id], message, round_need_id, created)
	select @user_id, @message, @round_need_id, getutcdate()
	set @application_id = scope_identity()


	insert activity
	(item, round_id)
	select dbo.fn_activ_application(@application_id), @round_id

	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					dbo.fn_get_round(@round_id) as "*"
					for xml path ('Result')
				)
				

end try
begin catch 
	exec dbo.set_error @p, @r output
end catch 

GO
/****** Object:  StoredProcedure [api].[need_application_approve]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[need_application_approve]
@p xml,
@r xml output
as
begin try 

declare @token char(36),
		@status_fulfiled_id int,
		@round_need_id int,
		@user_id int,
		@user xml,
		@application xml
		
select	@token = @p.value('(Application/@token)[1]', 'char(36)')

-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null 
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------


	select @status_fulfiled_id = id from status where name = 'FULFILED'

	update application 
	set approved = getutcdate(),
	@round_need_id = round_need_id,
	@user_id = [user_id]
	where token = @token 




	set @application  = (
							select c.slug as "@companySlug",
									rn.name as "@need",
									rn.slug as "@needSlug",
									c.name as "@companyName"
							from application a
							join round_need rn
								on rn.id = a.round_need_id 
							join round r 
								on r.id = rn.round_id
							join company c
								on c.id = r.company_id
							where a.token = @token
							for xml path ('Application'), type
							)

	set @user = [dbo].[fn_get_user_mini](@user_id)



	update round_need
	set status_id = @status_fulfiled_id
	where id = @round_need_id

	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName",
					@user,
					@application
					for xml path ('Result')
				)
				

end try
begin catch 
	exec dbo.set_error @p, @r output
end catch 

GO
/****** Object:  StoredProcedure [api].[need_create]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[need_create]
@p xml,
@r xml output
as
begin try

	declare @name nvarchar(255),
			@description nvarchar(max),
			@category_id int,
			@category nvarchar(255),
			@dbMessage varchar(255)




	select @name = @p.value('(Need/@name)[1]', 'nvarchar(255)'),
		 @description = @p.value('(Need/@description)[1]', 'nvarchar(max)'),
		 @category = @p.value('(Need/@category)[1]', 'nvarchar(255)')
	


-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @name is null  or @category is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end


-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	
	select @category_id = id from category where name = @category
	
	if exists (select 1 from need where name = @name)
		set @dbMessage = 'Need_Already_Exists'
	else
		insert need
		(name, [description], category_id, [key])
		select @name, @description, @category_id, dbo.fn_create_key(@name)

	
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@dbMessage as "@dbMessage"
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch



GO
/****** Object:  StoredProcedure [api].[need_remove_tag]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[need_remove_tag]
@p xml,
@r xml output
as
begin try 




declare @round_need char(36), @tag char(36), @round_id int ,@round_need_id int

select @round_need = @p.value('(Round/Needs/@token)[1]', 'char(36)')
select @tag = @p.value('(Round/Needs/Tags/@name)[1]', 'char(36)')
		
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @round_need is null or @tag is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	select @round_id = round_id,
	@round_need_id = id
	from [round_need] 
	where  token = @round_need


	delete rnt
	from round_need_tag rnt
	join tag t
		on t.id = rnt.tag_id
	where round_need_id = @round_need_id
	and t.name = @tag


	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					dbo.fn_get_round(@round_id) as "*"
					for xml path ('Result')
				)
				

end try
begin catch 
	exec dbo.set_error @p, @r output
end catch 

GO
/****** Object:  StoredProcedure [api].[need_search]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[need_search]
@p xml, 
@r xml output
as
begin try 

declare @tag nvarchar(255),
@need xml

declare @tags table (name nvarchar(255))

insert @tags
(name)
select 
rows.n.value('(@name)[1]', 'nvarchar(255)')
from @p.nodes('Search/Tags')rows(n)

select @need = (
			select dbo.get_round_need(rn.id)
			from round_need rn
			join [round]  r
				on r.id = rn.round_id
			join status s
				on rn.status_id = s.id
			join round_need_tag rnt
				on rnt.round_need_id = rn.id
			join tag t
				on t.id = rnt.tag_id
			where t.name in (select name  from @tags)
			and published is not null
			and s.name not in ('PENDING', 'FULFILED')

			for xml path (''), type
	)

	select distinct s.*
	from round_need rn
	join status s
		on rn.status_id = s.id

	if @need is null
	set @need = 
	 (
			select dbo.get_round_need(x.id)
			from (select distinct top 4  rn.id 
					from round_need rn
					join status s
						on rn.status_id = s.id
					join [round]  r
						on r.id = rn.round_id
					where published is not null
					and s.name not in ('PENDING', 'FULFILED')
					)x
			for xml path (''), type
	)
		select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@need
	for xml path('Result')
	)



end try
begin catch
	exec dbo.set_error @p,  @r output
end catch

GO
/****** Object:  StoredProcedure [api].[need_search_location]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[need_search_location]
@p xml = null, 
@r xml output
as
begin try 

declare @need xml



select @need = (
			select dbo.get_round_need(rn.id)
			from round_need rn
			where rn.id  in (		select top 4 rn.id
									from round_need rn
									join status s
										on rn.status_id = s.id
									join [round] r
										on r.id = rn.round_id
									where published is not null
									and s.name not in ('PENDING', 'FULFILED')
									order by newid()
							)
			for xml path (''), type
				)


		select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@need
	for xml path('Result')
	)



end try
begin catch
	exec dbo.set_error @p,  @r output
end catch

GO
/****** Object:  StoredProcedure [api].[need_search_popular]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[need_search_popular]
@p xml = null, 
@r xml output
as
begin try 

declare @need xml



select @need = (
			select dbo.get_round_need(rn.id)
			from round_need rn
			where rn.id  in (		select top 4 rn.id
									from round_need rn
									join status s
										on rn.status_id = s.id
									join [round] r
										on r.id = rn.round_id
									left join application a
										on a.round_need_id  = rn.id
									where published is not null	
									and s.name not in ('PENDING', 'FULFILED')
									group by  rn.id,  rn.created
									order by count(*), rn.created desc
							)
			for xml path (''), type
				)


		select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@need
	for xml path('Result')
	)



end try
begin catch
	exec dbo.set_error @p,  @r output
end catch

GO
/****** Object:  StoredProcedure [api].[pledge_create]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [api].[pledge_create] 
@p xml,
@r xml output
as
begin try 

declare @name nvarchar(255),
		@network char(2),
		@network_id nvarchar(255),
		@picture nvarchar(255),
		@round_token char(36),
		@round_id  int,
		@dbMessage nvarchar(255),
		@round xml,
		@offer nvarchar(255),
		@offer_id int,
		@comment nvarchar(max),
		@pledge_id int



select @round_token = @p.value('(Round/@token)[1]', 'char(36)'),
@name = @p.value('(Round/Pledge/@name)[1]', 'nvarchar(255)'),
@network_id = @p.value('(Round/Pledge/@networkId)[1]', 'nvarchar(255)'),
@picture = @p.value('(Round/Pledge/@picture)[1]', 'nvarchar(255)'),
@network = @p.value('(Round/Pledge/@network)[1]', 'char(2)'),
@offer = @p.value('(Round/Pledge/@offerToken)[1]', 'char(36)'),
@comment = @p.value('(Round/Pledge/@comment)[1]', 'nvarchar(max)')

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @round_token is null or @network_id is null or @picture is null or @network is null or @offer is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	


select @round_id = id from round where token  = @round_token 

select @offer_id = o.id 
			from offer o
			join product p
				on p.id = o.product_id
			where p.id = @round_id
			and o.token =  @offer

if exists(select 1 from pledge where offer_id = @offer_id and network_id = @network_id and network = @network)
	set @dbMessage = 'AlreadyPledged'

else
begin

insert pledge 
(offer_id, name, picture, network, network_id , comment)
select @offer_id, @name, @picture, @network, @network_id, @comment
set @pledge_id = scope_identity()

insert activity
(item, round_id)
select dbo.fn_activ_pledge(@pledge_id), @round_id
end
select  @round  = dbo.fn_get_round(@round_id)

	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					@dbMessage as"@dbMessage",
					@round 
					for xml path ('Result')
				)
				

end try 
begin  catch 
	exec dbo.set_error @p, @r output
end  catch



GO
/****** Object:  StoredProcedure [api].[product_search_newest]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[product_search_newest]
@p xml = null, 
@r xml output
as
begin try 

declare @product xml



select @product = (
			select dbo.fn_get_companies(r.company_id)
			from product p
			join round r
				on r.id = p.id
			where p.id  in (		select top 4 rn.id
									from product rn
									order by rn.created desc
							)
			and r.published is not null
			for xml path (''), type
				)


		select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@product
	for xml path('Result')
	)



end try
begin catch
	exec dbo.set_error @p,  @r output
end catch

GO
/****** Object:  StoredProcedure [api].[round_activity]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [api].[round_activity]
@p xml,
@r xml output
as
begin try
declare @token char(36),
		@round_id int,
		@activity xml
		
select @token = @p.value('(Round/@token)[1]', 'char(36)')
	
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
if @token is null
						
	begin 
	raiserror	('insufficient params',
				16, -- severity.
				1) -- state
	end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	select @round_id = id from round where token = @token 

	select @activity = (
						select item as "*"
						from activity
						where round_id = @round_id
						order by created desc
						for xml path (''), type
						)

	select @r = (
			select 0 as "@status", 
			object_name(@@procid) as "@procName",
			@activity as "Activity"
			for xml path ('Result')
				)


end try
begin catch
	exec set_error @p , @r output
end catch



GO
/****** Object:  StoredProcedure [api].[round_assign_experts]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[round_assign_experts]
@p xml,
@r xml output
as
begin try

	declare @token char(36),
			@new_round int,
			@round xml,
			@round_id int

			
	declare @needs table (
							token char(36), 
							name nvarchar(255), 
							expert_first_name nvarchar(255), 
							expert_last_name nvarchar(255),
							expert_id nvarchar(255),
							expert_picture nvarchar(255),
							expert_headline nvarchar(255),
							intro_first_name nvarchar(255), 
							intro_last_name nvarchar(255),
							intro_id nvarchar(255) ,
							intro_picture nvarchar(255)
						)

	insert @needs
	(token , name, expert_first_name, expert_last_name, expert_id,expert_picture,expert_headline, intro_first_name,intro_last_name,intro_id, intro_picture) 
	select 
	rows.n.value('(@token)[1]', 'char(36)'),
	rows.n.value('(@name)[1]', 'nvarchar(255)'),
	experts.n.value('(@firstName)[1]', 'nvarchar(255)'),
	experts.n.value('(@lastName)[1]', 'nvarchar(255)'),
	experts.n.value('(@linkedinId)[1]', 'nvarchar(255)'),
	experts.n.value('(@picture)[1]', 'nvarchar(255)'),
	experts.n.value('(@headline)[1]', 'nvarchar(255)'),
	experts.n.value('(@introFirstName)[1]', 'nvarchar(255)'),
	experts.n.value('(@introLastName)[1]', 'nvarchar(255)'),
	experts.n.value('(@introLinkedinId)[1]', 'nvarchar(255)'),
	experts.n.value('(@introPicture)[1]', 'nvarchar(255)')
	from @p.nodes('Round/Needs') as rows(n)
	cross apply rows.n.nodes('Experts') as experts(n)

	select @token = @p.value('(Round/@token)[1]', 'char(36)')



-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	



	
	insert expert_round_need
	(round_need_id, expert_first_name, expert_last_name, expert_picture,expert_headline, expert_id, intro_first_name, intro_last_name, intro_picture, intro_id, created)
	select rn.id, t.expert_first_name, t.expert_last_name, t.expert_picture, t. expert_headline, t.expert_id,t.intro_first_name,t.intro_last_name, t.intro_picture, t.intro_id, getutcdate()
	from @needs t
	join round_need  rn
		on rn.token = t.token
	left join round_need rn2
		on rn2.id = rn.id
		and rn2.expert_id  = rn.expert_id
	where rn2.id is null 

	
	select @round_id = id from [round] where token = @token
			
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	dbo.fn_get_round(@round_id)
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch

GO
/****** Object:  StoredProcedure [api].[round_assign_services]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[round_assign_services]
@p xml,
@r xml output
as
begin try

	declare @token char(36),
			@round xml,
			@round_id int

	set @token = @p.value('(Round/@token)[1]' , 'char(36)')

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	


	insert service_round_need	
	(service_id, round_need_id)
	select sn.service_id, rn.id
	from [round] r
	join round_need rn
		on rn.round_id = r.id
	join need n
		on n.id = rn.need_id
	join service_need sn
		on sn.need_id = n.id
	where r.token = @token 


			
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName"
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch



GO
/****** Object:  StoredProcedure [api].[round_endorsement]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [api].[round_endorsement]
@p xml,
@r xml output
as
begin try
declare @token char(36),
		@endorser char(36),
		@endorsee_linkedin_id nvarchar(36),
		@round_need_id int,
		@endorser_id int,
		@endorsee_picture nvarchar(255),
		@endorsee_skills nvarchar(255),
		@endorsee_headline nvarchar(255),
		@endorsee_name nvarchar(255),
		@round_id int,
		@endorsement_id int


select @token = @p.value('(Need/@token)[1]', 'char(36)'),
		@endorser = @p.value('(Need/Endorsement/@endorserToken)[1]', 'char(36)'),
		@endorsee_linkedin_id = @p.value('(Need/Endorsement/@endorseeLinkedinId)[1]', 'nvarchar(255)'),

		@endorsee_picture = @p.value('(Need/Endorsement/@endorseePicture)[1]', 'nvarchar(255)'),
		@endorsee_skills = @p.value('(Need/Endorsement/@endorseeSkills)[1]', 'nvarchar(255)'),
		@endorsee_headline = @p.value('(Need/Endorsement/@endorseeHeadline)[1]', 'nvarchar(255)'),
		@endorsee_name = @p.value('(Need/Endorsement/@endorseeName)[1]', 'nvarchar(255)')

	
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
IF @token is null
						
	begin 
	raiserror	('insufficient params',
				16, -- severity.
				1) -- state
	end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	
	select	@round_need_id = id, 
			@round_id = round_id
	from round_need where token = @token 
	select @endorser_id = id from [user] where token  = @endorser 

	insert round_need_endorsement
	(round_need_id, endorser_id, endorsee_linkedin_id, created, endorsee_headline, endorsee_picture, endorsee_skills, endorsee_name)
	select @round_need_id, @endorser_id, @endorsee_linkedin_id, getutcdate(), @endorsee_headline, @endorsee_picture, @endorsee_skills, @endorsee_name
	set @endorsement_id = scope_identity()

	insert activity
	(item, round_id)
	select dbo.fn_activ_endorsement(@endorsement_id), @round_id


	select @r = (
			select 0 as "@status", 
			object_name(@@procid) as "@procName"
			for xml path ('Result')
				)


end try
begin catch
	exec set_error @p , @r output
end catch



GO
/****** Object:  StoredProcedure [api].[round_funding_invest]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [api].[round_funding_invest]
@p xml,
@r xml output
as
begin try

	declare @amount int,
			@valuation int,
			@round_id int,
			@token char(36),
			@userToken char(36),
			@user_id int

	select 
		@token = @p.value('(Round/@token)[1]', 'char(36)'),
		@amount = @p.value('(Round/Funding/Investment/@amount)[1]', 'int'),
		@userToken = @p.value('(Round/Funding/Investment/User/@token)[1]', 'char(36)')

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	if @token is null or @amount is null or @userToken is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	
	
	select @user_id = id from [user] where token = @userToken 
	select @round_id = id from [round] where token = @token
	

	insert investment 
	([user_id],round_id, amount)
	select @user_id,@round_id, @amount 

			
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	dbo.fn_get_round(@round_id)
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch

GO
/****** Object:  StoredProcedure [api].[round_funding_target]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[round_funding_target]
@p xml,
@r xml output
as
begin try

	declare @amount int,
			@valuation int,
			@round_id int,
			@token char(36),
			@description nvarchar(max),
			@contract nvarchar(1024)

	select 
		@token = @p.value('(Round/@token)[1]', 'char(36)'),
		@amount = @p.value('(Round/Funding/@amount)[1]', 'int'),
		@valuation = @p.value('(Round/Funding/@valuation)[1]', 'int'),
		@description = @p.value('(Round/Funding/@description)[1]', 'nvarchar(max)'),
		@contract = @p.value('(Round/Funding/@contract)[1]', 'nvarchar(1024)')

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null or @amount is null or @valuation is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end


-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	

	update [round]
	set funding = @amount,
		valuation = @valuation,
		@round_id = id,
		funding_description = @description,
		funding_contract = @contract
	where token = @token 

			
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	dbo.fn_get_round(@round_id)
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch

GO
/****** Object:  StoredProcedure [api].[round_need_add]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [api].[round_need_add]
@p xml,
@r xml output
as
begin try 


declare @token char(36), 
		@round_id int,
		@status_id int


select	@token = @p.value('(Round/Needs/@token)[1]', 'char(36)')

		

	declare @tags table (name nvarchar(255))

	
		
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	select @status_id = id from status where name = 'ADDED'
	

	update rn
	set 
	status_id = @status_id,
	@round_id = round_id
	from round_need rn
	where token = @token




	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					dbo.fn_get_round(@round_id) as "*"
					for xml path ('Result')
				)
				

end try
begin catch 
	exec dbo.set_error @p, @r output
end catch 

GO
/****** Object:  StoredProcedure [api].[round_need_create]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[round_need_create]
@p xml,
@r xml output
as
begin try 


declare @token char(36), 
		@round char(36), 
		@round_id int,
		@cash int,
		@equity int,
		@description nvarchar(max),
		@picture nvarchar(255),
		@name nvarchar(255),
		@round_need_id int,
		@status_id nvarchar(255),
		@need xml
		

select	@round = @p.value('(Round/@token)[1]', 'char(36)'),
		@cash = @p.value('(Round/Needs/@cash)[1]', 'int'),
		@equity = @p.value('(Round/Needs/@equity)[1]', 'int'),
		@description = @p.value('(Round/Needs/@customText)[1]', 'nvarchar(max)'),
		@picture = @p.value('(Round/Needs/@picture)[1]', 'nvarchar(255)'),
		@name = @p.value('(Round/Needs/@name)[1]', 'char(36)')
		

	declare @tags table (name nvarchar(255))

	insert @tags
	(name) 
	select 
	rows.n.value('(@name)[1]', 'nvarchar(255)')
	from @p.nodes('Round/Needs/Tags')rows(n)
		
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @round is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	select @round_id = id from [round] where token = @round
	select @status_id = id from status where name = 'CUSTOMISED'


	if not exists (select 1 from need where name =  @name)
		insert need
		(name, created, expert, [key], category_id, description, picture)
		select @name, getutcdate(), 0,[dbo].[fn_create_key](@name), 5, null, @picture

	insert round_need
	(round_id, need_id, created, status_id, token, name, customText, equity, cash, picture, slug)
	select @round_id, id, getutcdate(), @status_id, newid(), @name, @description,@equity, @cash , @picture, [dbo].[fn_create_slug](@name)
	from need 
	where name = @name
	set @round_need_id = scope_identity()


	insert tag
	(name)
	select name 
	from @tags 
	where name not in (select name from tag)

	insert round_need_tag
	(round_need_id , tag_id)
	select @round_need_id , id
	from tag t
	join @tags ta
		on t.name = ta.name 


	set @need = (
			
							select rn.name as "@name",
							rn.slug as "@slug",
							[key] as "@key",
							rn.token as "@token",
							rn.customtext as "@customText",
							n.summary as "@summary",
							st.name as "@status",
							c.name as "@category",
							expert as "@isExpert",
							rn.picture as "@picture",
							n.description as "@description",
							rn.cash as "@cash",
							rn.equity  as "@equity",
							(
								select message as "@message",
										created as "@created",
										token as "@token",
										case when approved is not null then 1 else 0 end as "@approved",
								(
									select picture as "@picture",
											name as "@name",
											token as "@token",
											headline as "@headline"
									from [user] u
									where u.id = a.[user_id]
									for xml path ('User'), type
								)
								from application a
								where rn.id = a.round_need_id
								for xml path ('Applications'), type
							),
							(
								select name as "@name",
										[description] as "@description"
								from round_need_tag rnt
								join tag t
									on t.id = rnt.tag_id
								where rnt.round_need_id = rn.id
								for xml path ('Tags'), type
							),
							(
								select distinct s.name as "@name",
										s.url as "@url",
										s.worker as "@worker",
										s.picture as "@picture",
										s.logo as "@logo"
								from service_round_need srn
								join v_service s
									on srn.service_id = s.id
								where srn.round_need_id = rn.id
								for xml path ('Services'), type
								),
								(
									select expert_first_name  as "@firstName",
											expert_last_name as "@lastName", 
											expert_picture as "@picture", 
											expert_id as "@linkedinId", 
											expert_headline as "@headline",
											intro_first_name as "@introFirstName", 
											intro_last_name as "@introLastName", 
											intro_picture as "@introPicture", 
											intro_id as "@introLinkedinId"
									from expert_round_need ern
									where ern.round_need_id = rn.id
									for xml path ('Experts'), type
								),

									(
									select u.name as "@endorserName",
									u.picture as "@endorserPicture",
									rne.endorsee_name as "@endorseeName",
									rne.endorsee_headline as "@endorseeHeadline",
									rne.endorsee_picture as "@endorseePicture",
									rne.endorsee_skills as "@endorseeSkills"
									from round_need_endorsement rne
									join [user] u
										on u.id = endorser_id
									where rne.round_need_id = rn.id
									for xml path ('Endorsements'), type
								)
							from round_need rn
							join status st
								on st.id = rn.status_id
							join need n			
								on n.id = rn.need_id
							join category c
								on c.id = n.category_id
							left join v_service s
								on s.id = rn.service_id
							where rn.id = @round_need_id
							for xml path ('Need') ,type		
							)


	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					@need as "*"
					for xml path ('Result')
				)
				

end try
begin catch 
	exec dbo.set_error @p, @r output
end catch 

GO
/****** Object:  StoredProcedure [api].[round_need_edit]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[round_need_edit]
@p xml,
@r xml output
as
begin try 


declare @token char(36), 
		@round char(36), 
		@round_id int,
		@cash int,
		@equity int,
		@description nvarchar(max),
		@picture nvarchar(255),
		@name nvarchar(255),
		@round_need_id int,
		@status_id nvarchar(255)


select	@token = @p.value('(Round/Needs/@token)[1]', 'char(36)'),
		@round = @p.value('(Round/Needs/@token)[1]', 'char(36)'),
		@cash = @p.value('(Round/Needs/@cash)[1]', 'int'),
		@equity = @p.value('(Round/Needs//@equity)[1]', 'int'),
		@description = @p.value('(Round/Needs/@customText)[1]', 'nvarchar(max)'),
		@picture = @p.value('(Round/Needs/@picture)[1]', 'nvarchar(255)'),
		@name = @p.value('(Round/Needs/@name)[1]', 'nvarchar(255)')
		

	declare @tags table (name nvarchar(255))

	insert @tags
	(name) 
	select 
	rows.n.value('(@name)[1]', 'nvarchar(255)')
	from @p.nodes('Round/Needs/Tags')rows(n)
		
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	select @status_id = id from status where name = 'CUSTOMISED'
	

	update rn
	set 
	cash = @cash ,
	equity = @equity,
	customText = @description,
	name = @name,
	picture = @picture,
	@round_id = round_id,
	@round_need_id = id,
	status_id = @status_id
	from round_need rn
	where token = @token

	delete round_need_tag
	where round_need_id = @round_need_id

	insert tag
	(name)
	select name 
	from @tags 
	where name not in (select name from tag)

	insert round_need_tag
	(round_need_id , tag_id)
	select @round_need_id , id
	from tag t
	join @tags ta
		on t.name = ta.name 


	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					dbo.fn_get_round(@round_id) as "*"
					for xml path ('Result')
				)
				

end try
begin catch 
	exec dbo.set_error @p, @r output
end catch 

GO
/****** Object:  StoredProcedure [api].[round_publish]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[round_publish]
@p xml = null,
@r xml output
as
begin try

declare @token char(36), @round_id int, @company_id int

select @token = @p.value('(Round/@token)[1]', 'char(36)')

-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

update [round]
set published = getutcdate(),
@round_id = id,
@company_id = company_id
where token = @token
	

insert activity 
(item , round_id)
select [dbo].[fn_activ_company_publish](@company_id), @round_id

	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					dbo.fn_get_round(@round_id) as "*"
					for xml path ('Result')
				)

end try
begin  catch
	exec dbo.set_error @p , @r output
end catch

GO
/****** Object:  StoredProcedure [api].[round_remove_need]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[round_remove_need]
@p xml,
@r xml output
as
begin try 


declare @token char(36), @round char(36), @round_id int ,
@round_need_id int 

select @token = @p.value('(Round/Needs/@token)[1]', 'char(36)')
select @round = @p.value('(Round/@token)[1]', 'char(36)')
		
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	select @round_id = id 
	from [round] 
	where  token = @round

	select @round_need_id = id from round_need where token = @token 

	delete [dbo].[round_need_endorsement] where round_need_id = @round_need_id

	delete service_round_need
	where round_need_id = @round_need_id

	delete expert_round_need
	where round_need_id = @round_need_id

	
	delete rnt
	from round_need_tag rnt
	join round_need rn
		on rn.id = rnt.round_need_id
	where rn.token = @token 

	delete round_need
	where token = @token 



	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					dbo.fn_get_round(@round_id) as "*"
					for xml path ('Result')
				)
				

end try
begin catch 
	exec dbo.set_error @p, @r output
end catch 

GO
/****** Object:  StoredProcedure [api].[round_send_to_mentor]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [api].[round_send_to_mentor]
@p xml,
@r xml output
as
begin try

declare @token char(36),
		@round_id int,
		@company_id int


select @token = @p.value('(Round/@token)[1]' ,'char(36)')

-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------



	update round
	set sent_to_mentor = getutcdate(),
	@company_id = company_id,
	@round_id = id
	where token = @token 

	insert activity 
	(item , round_id)
	select [dbo].[fn_activ_company_approval](@company_id), @round_id

	select @r = (
			select 0 as "@status", 
			object_name(@@procid) as "@procName",
			[dbo].[fn_get_company](@company_id) 
			for xml path ('Result')
		)


end try
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [api].[service_search]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [api].[service_search]
@p xml,
@r xml output
as
begin try

	declare @service nvarchar(255),
			@service_xml  xml

	select @service = @p.value('(Service/@name)[1]', 'nvarchar(255)')


-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @service is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	


	select @service_xml = (
						select name as "@name"
						from service
						where name like @service +'%'
						order by len(name) asc
						for xml path('Services')
					)

	
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@service_xml
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch

GO
/****** Object:  StoredProcedure [api].[tag_search]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[tag_search]
@p xml,
@r xml output
as
begin try

	declare @tag nvarchar(255),
			@tag_xml  xml

	select @tag = @p.value('(Tag/@name)[1]', 'nvarchar(255)')


-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @tag is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	


	select @tag_xml = (
						select name as "@name"
						from tag
						where name like @tag +'%'
						order by len(name) asc
						for xml path('Tags')
					)

	
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@tag_xml
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch

GO
/****** Object:  StoredProcedure [api].[tag_top_20]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[tag_top_20]
@p xml,
@r xml output
as
begin try

	declare @tag nvarchar(255),
			@tag_xml  xml



	select @tag_xml = (
						select top 20 name as "@name"
						from tag t
						join(
							select tag_id, count(*) no
							from need_tag tg
							join need n
								on n.id = tg.need_id
							join round_need rn
								on rn.need_id = n.id
							join round r
								on r.id = rn.round_id
							join status s
								on s.id = rn.status_id
							join template_need tn
								on tn.need_id = n.id
							join template t
								on t.id = tn.template_id 
							where t.active = 1
							and  s.name not in ('PENDING', 'FULFILED')
							and published is not null
							group by tag_id
							)x
						on x.tag_id = t.id
						order by [no] desc
						for xml path('Tags')
					)

	
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@tag_xml
	for xml path('Result')
	)


end try 
begin catch
	exec dbo.set_error @p, @r output
end catch

GO
/****** Object:  StoredProcedure [api].[top_mentors]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [api].[top_mentors] 
@p xml = null,
@r xml output
as
begin try 

declare @mentors xml

set @mentors = (
			select [dbo].[fn_get_user_mini]([user_id])
					from (
					select distinct top 5 [user_id], startup_value
					from user_company uc
					join [user] u
						on u.id = uc.[user_id]
					join role r
						on r.id = uc.role_id
					where r.name = 'MENTOR' 
					order by startup_value  desc
					)x
					for xml path (''), type
				)

	

	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					 @mentors as "Mentors"
					for xml path ('Result')
				)
				

end try
begin catch 
	exec dbo.set_error @p, @r output
end catch 

GO
/****** Object:  StoredProcedure [api].[user_check_slug_available]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [api].[user_check_slug_available]
@p xml,
@r xml output
as
begin try


declare @slug nvarchar(255),
		@dbMessage varchar(255)
		
select @slug = @p.value('(User/@slug)[1]','nvarchar(255)')
	  
-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if   @slug is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1) -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

if exists(select 1 from v_slug where @slug = slug)
	set @dbMessage = 'SLUG_TAKEN'

	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					@dbMessage as "@dbMessage"
					for xml path ('Result')
				)


end try
begin  catch
	exec dbo.set_error @p , @r output
end catch

GO
/****** Object:  StoredProcedure [api].[user_connections_save]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [api].[user_connections_save]
@p xml,
@r xml output
as
begin try


declare @token char(36), 
		@user_li_id nvarchar(255)

declare @connections table(id varchar(255))

select @token = @p.value('(User/@token)[1]', 'char(36)')	


	insert @connections
	(id)
	select 
	rows.n.value('(@id)[1]', 'nvarchar(255)')
	from @p.nodes('User/Users/Profile')rows(n)

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end

	if not exists (select 1 from @connections)
		begin 
		raiserror	(N'no users passed in',
					16, -- severity.
					1); -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	

	select @user_li_id = linkedin_id from [user] where token = @token

	delete from [edge] 
	where [user_linkedin_id] = @user_li_id

	insert [edge]
	([user_linkedin_id], [user_connection])
	select @user_li_id, c.id
	from @connections c
	
select @r = (
select 0 as "@status", 
object_name(@@procid) as "@procName"
for xml path('Result')
)




end try 
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [api].[user_email_login]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [api].[user_email_login]
@p xml,
@r xml output
as
begin try

declare @name nvarchar(255),
		@user xml,
		@dbMessage varchar(255),
		@email varchar(255),
		@pwd varchar(255),
		@user_id int
		
select @pwd = [dbo].[fn_get_md5_hash](@p.value('(User/@pwd)[1]','nvarchar(255)')),
		@email = @p.value('(User/@email)[1]','nvarchar(255)')	

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if   @pwd is null or @email is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1) -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

select @user_id = id from [user] where pwd = @pwd  and @email = email
if @user_id is null
	set @dbMessage = 'LOGIN_FAILED'

	select @r = (
		select 0 as "@status", 
		object_name(@@procid) as "@procName",
		@dbMessage as "@dbMessage",
		dbo.fn_get_user_base(@user_id) as "*"
		for xml path('Result')
		)

end try
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [api].[user_email_signup]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [api].[user_email_signup]
@p xml,
@r xml output
as
begin try
	declare @email nvarchar(255),
			@pwd varchar(255),
			@name nvarchar(255),
			@user xml,
			@new_user_id int,
			@dbMessage varchar(255)

	select @email = @p.value('(User/@email)[1]','nvarchar(255)'),
	@pwd = @p.value('(User/@pwd)[1]','nvarchar(255)'),
	@name = @p.value('(User/@name)[1]','nvarchar(255)')

-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	IF @email is null or @pwd is null or @name is null
						
		begin 
		raiserror	('no facebook id passed in',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	if exists(	select * 
				from [user] 
				where email=@email 
			)
		set @dbMessage = 'EMAIL_TAKEN' 
	else
	begin
		insert [user]
		(token, email, pwd, name)
		select newid(), @email, [dbo].[fn_get_md5_hash](@pwd), @name
		set @new_user_id = scope_identity()

	
	end
	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName",
	@dbMessage as "@dbMessage",
	dbo.fn_get_user_base(@new_user_id)
	for xml path('Result')
	)

end try
begin catch
 exec dbo.set_error @p, @r output
end catch
GO
/****** Object:  StoredProcedure [api].[user_facebook_connect]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[user_facebook_connect]
@p xml,
@r xml output
as
begin try

	declare 
		@name nvarchar(255),
		@access_token nvarchar(255),
		@email nvarchar(255),
		@token char(36),
		@user_id int,
		@dbMessage varchar(255),
		@facebook_id bigint,
		@user_token varchar(255), 
		@picture nvarchar(255),
		@suggested_pwd varchar(255),
		@gender varchar(255),
		@dob date

		
	select 
	@token = @p.value('(User/@token)[1]','char(36)'),
	@facebook_id = @p.value('(User/Profile/@id)[1]','bigint'),
	@name = @p.value('(User/Profile/@name)[1]','nvarchar(255)'), 
	@email = @p.value('(User/Profile/@email)[1]','nvarchar(255)'), 	
	@access_token = @p.value('(User/Profile/@accessToken)[1]','nvarchar(255)'), 	
	@picture = @p.value('(User/Profile/@picture)[1]','nvarchar(255)'),
	@gender = @p.value('(User/Profile/@gender)[1]','nvarchar(255)'),
	@dob = @p.value('(User/Profile/@dob)[1]','date')


-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	IF @facebook_id is null or @name is null or @email is null or @access_token is null or @picture is null 
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------


--NOTE this cant handle an fb only use who has changed his email address. in this case we create a new fb user 
	if @token is null -- user is not logged in
	begin 
	
		if not exists (select 1  -- email and facebook_id dont exist
					from [user] u
					where facebook_id = @facebook_id -- incase facebook user changes their email
					or email = @email
					)
		begin
			set @dbMessage = 'NEWUSER'

			insert [user]
			(token, name, email, fb_picture, facebook_id, fb_access_token, pwd, gender, dob)
			select newid(), @name, @email, @picture, @facebook_id, @access_token, [dbo].[fn_get_md5_hash](@suggested_pwd), left(@gender,1), @dob
			set @user_id = scope_identity()
	
		end
		if  @dbMessage is null and exists (select 1 -- an email user has already signed up with the fb users pwd so we merge
				from [user] u
				where facebook_id is null -- email only user
				and email = @email
				)
		begin
			set @dbMessage = 'MERGING_WITH_EMAIL_USER'
			update [user]
			set fb_picture = @picture,
				fb_access_token = @access_token,
				name = isnull(name, @name),
				facebook_id = @facebook_id,
				@user_id = id
			where email = @email
		end
		if  @dbMessage is null and exists (select 1 -- an email user has already signed up with the fb users pwd so we merge
				from [user] u
				where facebook_id = @facebook_id -- fb user who has changed their email address
				and email != @email
				)
		begin
			set @dbMessage = 'FB_USER_WITH_CHANGED_EMAIL'
			update [user]
			set fb_picture = @picture,
				fb_access_token = @access_token,
				name = isnull(name, @name),
				@user_id = id
			where facebook_id = @facebook_id
		end

		if @dbmessage is null -- so this is must be  a known fb with unchanged email user logging in
		begin
		
			update [user]
			set fb_picture = @picture,
				fb_access_token = @access_token,
				name = isnull(name, @name),
				@user_id = id
			where email = @email
			select 12, @user_id, @email
		end		
	end
	else
	begin -- user is logged in with email
		-- we dont update email here in case another user already is using it
		update [user]
		set fb_picture = @picture,
			fb_access_token = @access_token,
			name = @name,
			@user_id = id,
			facebook_id = @facebook_id
		where token = @token
	end

	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					@dbMessage as "@dbMessage",
					dbo.fn_get_user_base(@user_id) as "*"
					for xml path ('Result')
				)
				
		
	
end try
begin catch
	exec dbo.set_error @p, @r OUTPUT
end catch














GO
/****** Object:  StoredProcedure [api].[user_facebook_value]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[user_facebook_value]
@p xml,
@r xml output
as
begin try

	declare 
		@token char(36),
		@startup_value int,
		@link nvarchar(255)

		
	select 
	@token = @p.value('(User/@token)[1]','char(36)'),
	@startup_value = @p.value('(User/@fbValue)[1]','int'),
	@link =  @p.value('(User/@fbLink)[1]','nvarchar(255)')
	
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	IF @token is null or @startup_value is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	update [user]
	set fb_value = @startup_value,
		fb_link = @link
	where token = @token 


	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName"
					for xml path ('Result')
				)
				
		
	
end try
begin catch
	exec dbo.set_error @p, @r OUTPUT
end catch




GO
/****** Object:  StoredProcedure [api].[user_friends]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [api].[user_friends]
@p xml,
@r xml output
as
begin try

declare @token char(36),
@slug nvarchar(255),
@user_id int,
@friends xml
		
	
select @token = @p.value('(User/@token)[1]','char(36)'),
	@slug = @p.value('(User/@slug)[1]','char(36)')
		

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if   isnull(@token, @slug) is null 
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1) -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

select @user_id = id from [user] where token = @token or slug = @slug

set @friends = (
	
			select u.token as "@token",
					u.slug as "@slug",
			(select u2.name as "@name",
					u2.picture as "@picture",
					u2.slug as "@slug",
					u2.token as "@token",
					u2.startup_value as "@startupValue",
					u2.headline as "@headline",
					(
						select s.name as "@name"
						from user_skill us
						join skill s
							on us.skill_id = s.id
						where us.user_id = u2.id
						for xml path ('Skills'), type
					)
					from [edge] e
					join [user] u2
						on e.user_connection = u2.linkedin_id
					where e.user_linkedin_id = u.linkedin_id
					for xml path('Users'), type
			)
			from [user] u
			where u.id = @user_id
			for xml path ('User'), type
)

	select @r = (
		select 0 as "@status", 
		object_name(@@procid) as "@procName",
		@friends
		for xml path('Result')
		)

end try
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [api].[user_friends_companies]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [api].[user_friends_companies]
@p xml,
@r xml output
as
begin try

declare @token char(36),
@slug nvarchar(255),
@user_id int,
@companies xml
		
	
select @token = @p.value('(User/@token)[1]','char(36)'),
	@slug = @p.value('(User/@slug)[1]','char(36)')
		

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if   isnull(@token, @slug) is null 
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1) -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

select @user_id = id from [user] where token = @token or slug = @slug

declare @friends table  (id int, name nvarchar(255))


insert @friends
(id, name)
select u2.id as id , 
	u2.name as name
from [user] u
join edge e
	on e.user_linkedin_id = u.linkedin_id
join [user] u2
	on u2.linkedin_id = e.user_connection
where u.id = @user_id


set @companies = (
	
	select c.name as "@name",   
			c.pitch as "@pitch",
			 c.logo as "@logo",
			 c.slug as "@slug",
			 [dbo].[fn_get_company_value] (c.id) as "@totalValue",
			 (
				select cp.url as "@url"
				from company_picture cp
				where cp.company_id = c.id
				for xml path ('Pictures'), type		 
	 ),
	 (
			select u3.name as "@name",
					u3.slug as "@slug",
					u3.picture as "@picture",
					u3.headline as "@headline",
					u3.token as "@token",
					(
						select r.name as "@name"
						from role r
						where r.id = uc.role_id
						for xml path ('Roles'), type					
					)
					
			from [user_company] uc
			join  @friends x 
			on uc.user_id = x.id
			join [user] u3
				on u3.id = uc.user_id
			where company_id=c.id 
			for xml path ('Users'), type
	 )
	from company c
	join user_company uc
		on uc.company_id = c.id
	join  @friends x 
	on uc.user_id = x.id
	for xml path ('Companies'), type
)

	select @r = (
		select 0 as "@status", 
		object_name(@@procid) as "@procName",
		@companies
		for xml path('Result')
		)

end try
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [api].[user_get_needs]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[user_get_needs]
@p xml = null,
@r xml output
as
begin try

declare @needs xml


select @needs =  (
					select n.name as "@name",
					[key]  as "@key",
					c.name  as"@category"
					from need n
					join category c
							on  c.id = n.category_id
					for xml path ('Needs'), type
			)


	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					@needs
					for xml path ('Result')
				)


end try
begin  catch
	exec dbo.set_error @p , @r output
end catch

GO
/****** Object:  StoredProcedure [api].[user_get_template_needs]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [api].[user_get_template_needs]
@p xml,
@r xml output
as
begin try

declare @key nvarchar(255), 
		@template xml

select @key = @p.value('(Template/@key)[1]','nvarchar(255)')

select @template =  (
					select name as "@name",
					[key] as "@key",
					[description] as "@description",
					picture as "@picture",
					logo as "@logo",
					(
						select n.name as "@name",
						n.[key] as "@key",
						n.[description] as "@description",
						n.summary as "@summary",
						c.name as "@category",
						(
								select top 5 name as "@name",
										[description] as "@description"
								from need_tag nt
								join tag t
									on t.id = nt.tag_id
								where nt.need_id = n.id
								for xml path ('Tags'), type
							)
						from template_need tn
						join need n
							on n.id = tn.need_id
						join category c
							on  c.id = n.category_id
						where tn.template_id = t.id
						for xml path ('Need'), type
					)
					from template t
					where [key] = @key 
					for xml path ('Template'), type
			)


	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					@template
					for xml path ('Result')
				)


end try
begin  catch
	exec dbo.set_error @p , @r output
end catch

GO
/****** Object:  StoredProcedure [api].[user_get_templates]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[user_get_templates]
@p xml = null,
@r xml output
as
begin try

declare @templates xml


select @templates =  (
					select name as "@name",
					[key] as "@key",
					picture  as"@picture",
					logo as "@logo",
					[description] as "@description"
					from template t
					where active = 1
					for xml path ('Templates'), type
			)


	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					@templates
					for xml path ('Result')
				)


end try
begin  catch
	exec dbo.set_error @p , @r output
end catch

GO
/****** Object:  StoredProcedure [api].[user_info_set]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [api].[user_info_set]
@p xml,
@r xml output
as
begin try

declare @token char(36),
		@slug nvarchar(255),
		@user_id int,
		@type nvarchar(25),
		@amount float,
		@currency char(3),
		@currency_id int


declare  @skills table (name nvarchar(255)) 
declare  @roles table (name nvarchar(255)) 
		
	
select @token = @p.value('(User/@token)[1]','char(36)'),
		@slug = @p.value('(User/@slug)[1]','char(36)'),
		@type = @p.value('(User/@type)[1]','nvarchar(25)'),
		@currency = @p.value('(User/@currency)[1]','char(3)'),
		@amount = @p.value('(User/@investmentAmount)[1]','float')
		
-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if   @token is null and @slug is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1) -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	select @user_id = id from [user] where token = @token or slug = @slug

	select @currency_id = id from currency where name = @currency


	insert @skills
	(name)
	select 
	rows.n.value('(@name)[1]', 'nvarchar(255)')
	from @p.nodes('User/Skills')rows(n)

	insert @roles
	(name)
	select 
	rows.n.value('(@name)[1]', 'nvarchar(255)')
	from @p.nodes('User/Roles')rows(n)

	insert skill
	(name)
	select name 
	from @skills
	where name not in (select name from skill)

	delete from [user_role]
	where [user_id] = @user_id

	delete from [user_custom_skill]
	where [user_id]=@user_id
	
	
	insert [user_role]
	([user_id], role_id)
	select @user_id, r.id
	from [role] r
	join @roles qr
		on qr.name = r.name
		
		
	insert user_custom_skill
	([user_id], skill_id)
	select @user_id, s.id
	from @skills t
	join skill s
		on t.name = s.name 
	
	update [user]
	set currency_id = @currency_id,
	investment_amount = @amount
	where id = @user_id
			
	select @r = (
		select 0 as "@status", 
		object_name(@@procid) as "@procName",
		dbo.fn_get_user_base(@user_id) as "*"
		for xml path('Result')
		)

end try
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [api].[user_linkedin_connect]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[user_linkedin_connect]
@p xml,
@r xml output
as
begin try

	declare 
		@name nvarchar(255),
		@access_token nvarchar(255),
		@email nvarchar(255),
		@token char(36),
		@user_id int,
		@dbMessage varchar(255),
		@linkedin_id nvarchar(255),
		@user_token varchar(255), 
		@picture nvarchar(255),
		@suggested_pwd varchar(255),
		@gender varchar(255),
		@dob date,
		@secret varchar(255)

		
	select 
	@token = @p.value('(User/@token)[1]','char(36)'),
	@linkedin_id = @p.value('(User/Profile/@id)[1]','nvarchar(255)'),
	@name = @p.value('(User/Profile/@name)[1]','nvarchar(255)'), 
	@email = @p.value('(User/Profile/@email)[1]','nvarchar(255)'), 	
	@access_token = @p.value('(User/Profile/@accessToken)[1]','nvarchar(255)'), 	
	@picture = @p.value('(User/Profile/@picture)[1]','nvarchar(255)'),
	@gender = @p.value('(User/Profile/@gender)[1]','nvarchar(255)'),
	@dob = @p.value('(User/Profile/@dob)[1]','date'),
	@secret = @p.value('(User/Profile/@secret)[1]','varchar(255)')

	
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	IF @linkedin_id is null or @name is null or @email is null or @access_token is null or @picture is null 
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------




--NOTE this cant handle an fb only use who has changed his email address. in this case we create a new fb user 
	if @token is null -- user is not logged in
	begin 
	
		if not exists (select 1  -- email and linkedin_id dont exist
					from [user] u
					where linkedin_id = @linkedin_id -- incase facebook user changes their email
					or email = @email
					)
		begin
			set @dbMessage = 'NEWUSER'

		
			insert [user]
			(token, name, email, li_picture, linkedin_id, li_access_token, pwd, gender, dob, li_secret, slug)
			select newid(), @name, @email, @picture, @linkedin_id, @access_token, [dbo].[fn_get_md5_hash](@suggested_pwd), left(@gender,1), @dob, @secret, dbo.fn_create_user_slug(@name)
			set @user_id = scope_identity()

		end
		if  @dbMessage is null and exists (select 1 -- an email user has already signed up with the fb users pwd so we merge
				from [user] u
				where linkedin_id is null -- email only user
				and email = @email
				)
		begin
			set @dbMessage = 'MERGING_WITH_EMAIL_USER'
			update [user]
			set li_picture = @picture,
				li_access_token = @access_token,
				li_secret = @secret,
				name = isnull(name, @name),
				linkedin_id = @linkedin_id,
				@user_id = id
			where email = @email
		end
		if  @dbMessage is null and exists (select 1 -- an email user has already signed up with the fb users pwd so we merge
				from [user] u
				where linkedin_id = @linkedin_id -- fb user who has changed their email address
				and email != @email
				)
		begin
			set @dbMessage = 'FB_USER_WITH_CHANGED_EMAIL'
			update [user]
			set li_picture = @picture,
				li_access_token = @access_token,
				li_secret = @secret,
				name = isnull(name, @name),
				@user_id = id
			where linkedin_id = @linkedin_id
		end

		if @dbmessage is null -- so this is must be  a known fb with unchanged email user logging in
		begin
		
			update [user]
			set li_picture = @picture,
				li_access_token = @access_token,
				li_secret = @secret,
				name = isnull(name, @name),
				@user_id = id
			where email = @email
			select 12, @user_id, @email
		end		
	end
	else
	begin -- user is logged in with email
		-- we dont update email here in case another user already is using it
		update [user]
		set li_picture = @picture,
			li_access_token = @access_token,
			li_secret = @secret,
			name = @name,
			@user_id = id,
			linkedin_id = @linkedin_id
		where token = @token
	end

	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					@dbMessage as "@dbMessage",
					dbo.fn_get_user_base(@user_id) as "*"
					for xml path ('Result')
				)
				
		
	
end try
begin catch
	exec dbo.set_error @p, @r OUTPUT
end catch




GO
/****** Object:  StoredProcedure [api].[user_linkedin_login]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[user_linkedin_login]
@p xml,
@r xml output
as
begin try

 

	declare 
		@name nvarchar(255),
		@access_token nvarchar(255),
		@email nvarchar(255),
		@token char(36),
		@user_id int,
		@dbMessage varchar(255),
		@linkedin_id nvarchar(255),
		@user_token varchar(255), 
		@picture nvarchar(255),
		@suggested_pwd varchar(255),
		@gender varchar(255),
		@dob date,
		@secret varchar(255)
		
	select 
	@token = @p.value('(User/@token)[1]','char(36)'),
	@linkedin_id = @p.value('(User/Profile/@id)[1]','nvarchar(255)'),
	@name = @p.value('(User/Profile/@name)[1]','nvarchar(255)'), 
	@email = @p.value('(User/Profile/@email)[1]','nvarchar(255)'), 	
	@access_token = @p.value('(User/Profile/@accessToken)[1]','nvarchar(255)'), 	
	@picture = @p.value('(User/Profile/@picture)[1]','nvarchar(255)'),
	@gender = @p.value('(User/Profile/@gender)[1]','nvarchar(255)'),
	@dob = @p.value('(User/Profile/@dob)[1]','date'),
	@secret = @p.value('(User/Profile/@secret)[1]','varchar(255)')

	
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	IF @linkedin_id is null or @name is null or @email is null or @access_token is null or @picture is null 
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	select @user_id = id from [user] where linkedin_id=@linkedin_id


	update [user]
	set li_access_token = @access_token
	where id = @user_id
	

	if @user_id is null -- user does not exist
	begin 
		set @dbMessage='NO_USER_WITH_THIS_ACCOUNT' 	
		select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					@dbMessage as "@dbMessage"				
					for xml path ('Result')
		)
	end
	else
	begin
				select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 
					@dbMessage as "@dbMessage",
					dbo.fn_get_user_base(@user_id) as "*"
					for xml path ('Result')
				)
	end				

end try
begin catch
	exec dbo.set_error @p, @r OUTPUT
end catch




GO
/****** Object:  StoredProcedure [api].[user_linkedin_register]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[user_linkedin_register]
@p xml,
@r xml output
as
begin try

	declare 
		@name nvarchar(255),
		@access_token nvarchar(255),
		@email nvarchar(255),
		@token char(36),
		@user_id int,
		@dbMessage varchar(255),
		@linkedin_id nvarchar(255),
		@user_token varchar(255), 
		@picture nvarchar(255),
		@suggested_pwd varchar(255),
		@gender varchar(255),
		@dob date,
		@secret varchar(255),
		@slug nvarchar(255),
		@slug_check nvarchar(255)

		
	select 
	@linkedin_id = @p.value('(User/Profile/@id)[1]','nvarchar(255)'),
	@name = @p.value('(User/Profile/@name)[1]','nvarchar(255)'), 
	@email = @p.value('(User/Profile/@email)[1]','nvarchar(255)'), 	
	@access_token = @p.value('(User/Profile/@accessToken)[1]','nvarchar(255)'), 	
	@picture = @p.value('(User/Profile/@picture)[1]','nvarchar(255)'),
	@gender = @p.value('(User/Profile/@gender)[1]','nvarchar(255)'),
	@dob = @p.value('(User/Profile/@dob)[1]','date'),
	@secret = @p.value('(User/Profile/@secret)[1]','varchar(255)'),
	@slug = @p.value('(User/@slug)[1]','varchar(255)')
	
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	IF @linkedin_id is null or @name is null or @email is null or @access_token is null or @picture is null or @slug is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	select @user_id = id from [user] where linkedin_id=@linkedin_id

	select @slug_check = slug from [user] where slug = @slug

--NOTE this cant handle an fb only use who has changed his email address. in this case we create a new fb user 
	if @user_id is null and @slug_check is null-- we have a new user
	begin 
	
			insert [user]
			(token, name, email, li_picture, linkedin_id, li_access_token, pwd, gender, dob, li_secret, slug)
			select newid(), @name, @email, @picture, @linkedin_id, @access_token, [dbo].[fn_get_md5_hash](@suggested_pwd), left(@gender,1), @dob, @secret, @slug
			set @user_id = scope_identity()

			select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 					
					dbo.fn_get_user_base(@user_id) as "*"
					for xml path ('Result')
			)
	end
	else
	begin
		
		if @user_id is not null
		begin
			set @dbMessage = 'USER_ALREADY_REGISTERED'
		end
		else 
		begin
			set @dbMessage = 'USER_SLUG_TAKEN' 
		end
		select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName", 					
					@dbMessage as "@dbMessage"
					for xml path ('Result')
		)
	end
end try
begin catch
	exec dbo.set_error @p, @r OUTPUT
end catch




GO
/****** Object:  StoredProcedure [api].[user_linkedin_value]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [api].[user_linkedin_value]
@p xml,
@r xml output
as
begin try

	declare 
		@token char(36),
		@startup_value int

		
	select 
	@token = @p.value('(User/@token)[1]','char(36)'),
	@startup_value = @p.value('(User/@linkedinValue)[1]','int')
	
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	IF @token is null or @startup_value is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	update [user]
	set linkedin_value = @startup_value
	where token = @token 


	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName"
					for xml path ('Result')
				)
				
		
	
end try
begin catch
	exec dbo.set_error @p, @r OUTPUT
end catch




GO
/****** Object:  StoredProcedure [api].[user_profile]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [api].[user_profile]
@p xml,
@r xml output
as
begin try

declare @token char(36),
@slug nvarchar(255),
@user_id int
		
	
select @token = @p.value('(User/@token)[1]','char(36)'),
	@slug = @p.value('(User/@slug)[1]','char(36)')
		

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if   isnull(@token, @slug) is null 
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1) -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

select @user_id = id from [user] where token = @token or slug = @slug


	select @r = (
		select 0 as "@status", 
		object_name(@@procid) as "@procName",
		dbo.fn_get_user_base(@user_id) as "*"
		for xml path('Result')
		)

end try
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [api].[user_profile_mini]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [api].[user_profile_mini]
@p xml,
@r xml output
as
begin try

declare @token char(36),
@slug nvarchar(255),
@user_id int
		
	
select @token = @p.value('(User/@token)[1]','char(36)'),
	@slug = @p.value('(User/@slug)[1]','char(36)')
		

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if   isnull(@token, @slug) is null 
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1) -- state
		end
-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

select @user_id = id from [user] where token = @token or slug = @slug


	select @r = (
		select 0 as "@status", 
		object_name(@@procid) as "@procName",
		dbo.fn_get_user_mini(@user_id) as "*"
		for xml path('Result')
		)

end try
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [api].[user_skills_save]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [api].[user_skills_save]
@p xml,
@r xml output
as
begin try

declare @token char(36), 
		@user_id int, 
		@headline nvarchar(255),
		@interests nvarchar(max)

declare @skills table(name varchar(255))

select @token = @p.value('(User/@token)[1]', 'char(36)'),
		@headline = @p.value('(User/@headline)[1]', 'nvarchar(255)'),
		@interests = @p.value('(User/@interests)[1]', 'nvarchar(max)')

insert @skills
(name)
select 
rows.n.value('(@name)[1]', 'nvarchar(255)')
from @p.nodes('User/Skills')rows(n)

-------------------------------------------------------------------------------------------------------
-------------------------input validation--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	if @token is null
		begin 
		raiserror	(N'insufficient input params',
					16, -- severity.
					1); -- state
		end

	if not exists (select 1 from @skills)
		begin 
		raiserror	(N'no skills passed in',
					16, -- severity.
					1); -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------end input validation----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	
select @user_id = id from [user] where token = @token

insert skill
(name)
select name 
from @skills
where name not in (select name from skill)

delete user_skill
where [user_id] = @user_id

insert user_skill
([user_id], skill_id)
select distinct  @user_id, s.id
from @skills t
join skill s
	on t.name = s.name 

update [user]
set headline = @headline,
	interests = @interests
where id = @user_id

	
select @r = (
select 0 as "@status", 
object_name(@@procid) as "@procName"
for xml path('Result')
)




end try 
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [api].[user_xing_value]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [api].[user_xing_value]
@p xml,
@r xml output
as
begin try

	declare 
		@token char(36),
		@startup_value int,
		@link nvarchar(255)

		
	select 
	@token = @p.value('(User/@token)[1]','char(36)'),
	@startup_value = @p.value('(User/@xingValue)[1]','int'),
	@link =  @p.value('(User/@xingLink)[1]','nvarchar(255)')
	
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	IF @token is null or @startup_value is null
						
		begin 
		raiserror	('insufficient params',
					16, -- severity.
					1) -- state
		end

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------

	update [user]
	set xing_value = @startup_value,
		xing_link = @link
	where token = @token 


	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName"
					for xml path ('Result')
				)
				
		
	
end try
begin catch
	exec dbo.set_error @p, @r OUTPUT
end catch



GO
/****** Object:  StoredProcedure [dbo].[add_tag_to_need]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[add_tag_to_need]
@need_id int, 
@tag nvarchar(255)
as
begin 
declare @tag_id int


select @tag_id = id from tag where name = @tag

if @tag_id is null
begin
insert tag 
(name)
select @tag
set @tag_id = scope_identity()
end

insert need_tag
(need_id, tag_id)
select @need_id , @tag_id

end

GO
/****** Object:  StoredProcedure [dbo].[create_company]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[create_company](@user_id int)
as
begin 

declare @company_id int

insert company
(token)
select guid from v_newid
set @company_id  = scope_identity()

insert user_company
([user_id], company_id)
select @user_id, @company_id

return 1

end 

GO
/****** Object:  StoredProcedure [dbo].[delete_data]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[delete_data]
as
delete application 
delete dbo.round_need_endorsement
delete dbo.product
delete dbo.company_picture
delete dbo.company_update
delete from user_skill
delete dbo.product_picture
delete from round_need_tag
delete expert_round_need
delete round_need
delete [user]
delete [round] 
delete company
delete round_need
delete user_company
delete invite
delete product
delete round_need_Tag
delete application
delete offer
delete service_round_need
delete service_round_need
delete pledge
delete dbo.investment
delete dbo.activity

GO
/****** Object:  StoredProcedure [dbo].[example_proc]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[example_proc]
@p xml,
@r xml output
as
begin try


	select @r = (
	select 0 as "@status", 
	object_name(@@procid) as "@procName"
for xml path('Result')
	)

end try
begin catch
	exec dbo.set_error @p,  @r output
end catch


GO
/****** Object:  StoredProcedure [dbo].[set_error]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[set_error]
@params xml = null,
@result xml OUTPUT
AS
BEGIN

DECLARE @errmsg   NVARCHAR(2048),
		@severity TINYINT,
		@state    TINYINT,
		@errno    INT,
		@proc     SYSNAME,
		@lineno   INT,
		@returned_error_message NVARCHAR(4000),
		@error_id INT
		
		SELECT 
		@errmsg = ISNULL(error_message(),''), 
		@severity = ISNULL(error_severity(),''),   
		@state  = ISNULL(error_state(),''), 
		@errno = ISNULL(error_number(),''),
		@proc   = ISNULL(error_procedure(),''),
		@lineno = ISNULL(error_line(),'')
		
		SELECT @returned_error_message = '*** ' + quotename(@proc) + 
			', ' + ltrim(str(@lineno)) + '. Errno ' + 
			ltrim(str(@errno)) + ': ' + @errmsg
	


	INSERT dbo.errors
	(
	de_error_number, 
	de_error_severity, 
	de_error_state, 
	de_error_procedure, 
	de_error_params, 
	de_error_line, 
	de_error_message, 
	de_error_date, 
	de_login
	)
	SELECT
    @errno, 
	@severity,
    @state, 
    @proc,
    @params, 
    @lineno,
    @errmsg,
    GETUTCDATE(),
	system_user
	SET @error_id = SCOPE_IDENTITY()

	/*
	if db_name() != 'BurnPlus_dev'
	
	EXEC msdb.dbo.sp_send_dbmail
	@profile_name = 'BurnPlus',
	@recipients = 'errors@hackandcraft.com',
	@body = @errmsg,
	@subject = 'DB ERROR - BurnPlus' ;
	*/
	
	SELECT @result = (
				SELECT @error_id as "@status", 
				@returned_error_message as "@errorMessage",
				object_name(@@PROCID) as "@procName"
				FOR XML PAth ('Result') , type
				)

		
END




GO
/****** Object:  StoredProcedure [mess].[dequeue_message]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [mess].[dequeue_message]
@p xml = null,
@r xml output
as
begin try
declare @messages varchar(max)


update dbo.message_queue
set @messages = isnull(@messages, '') + cast(message as nvarchar(max)),
retry = retry + 1,
fetched = getutcdate()
where [status_id] in (1,2)
and retry <10
and datediff(hh, isnull(fetched,getutcdate() - 1), getutcdate())> 1


	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@procName",
					cast(@messages as xml) as "*"
					for xml path ('Result')
					)
end try
begin catch
	exec dbo.set_error @p, @r output
end catch


GO
/****** Object:  StoredProcedure [mess].[enqueue_message]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create proc [mess].[enqueue_message]
@p xml,
@r xml output
as
begin try

	declare @status_id int
	select @status_id = id from message_status where name ='PENDING'
	insert message_queue
	([message], status_id, retry)
	select @p, @status_id, 0
	
	
		
	select @r = (
					select 0 as "@status", 
					object_name(@@procid) as "@proc_name"
					for xml path ('Result')
				)
	
end try
begin catch
	exec dbo.set_error @p, @r output
end catch 


GO
/****** Object:  StoredProcedure [mess].[set_message_status]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  proc [mess].[set_message_status]
@p xml,
@r xml output
as
begin try
declare @status varchar(255),
		@messageid varchar(255),
		@status_id int,
		@result xml
		
	
select @status = @p.value('(MessageStatus/@status)[1]','varchar(255)'),
		@messageid = @p.value('(MessageStatus/Message/@id)[1]','varchar(255)')


select @status_id = id from message_status where @status = [name]
-------------------------------------------------------------------------------------------------------
-------------------------INPUT VALIDATION--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
	IF @messageid is null 
						
		BEGIN 
		RAISERROR	(N'insuffcient params',
					16, -- Severity.
					1) -- state
		END
	IF @status_id is null 
						
		BEGIN 
		RAISERROR	(N'status not found',
					16, -- Severity.
					1); -- state
		END

-------------------------------------------------------------------------------------------------------
-------------------------END INPUT VALIDATION----------------------------------------------------------
-------------------------------------------------------------------------------------------------------	
		
		update message_queue
		set status_id = @status_id
		where @messageid = ref
		
	SELECT @r = (
					SELECT 0 as status, 
					object_name(@@PROCID) as proc_name
					FOR XML RAW ('Result')
					)

end try
begin catch
	exec dbo.set_error @p, @r output
end catch







GO
/****** Object:  UserDefinedFunction [dbo].[fn_activ_application]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_activ_application](@application_id int)
returns xml
as
begin 

declare @item   xml

set @item =(
			select 'APPLICATION' as "@type",
				a.created as "@created",
				a.message as "Application/@message",
				logo as "Application/@comapnyLogo",
				c.name as "Application/@companyName",
				c.token as "Application/@companyToken", 
				c.slug as "Application/@companySlug",
				rn.name as "Application/@need",
				rn.token as "Application/@needToken",
				rn.slug as "Application/@needSlug",
				u.token as "Application/User/@token",
				u.slug as "Application/User/@slug",
				email as "Application/User/@email",
				headline as "Application/User/@headline",
				u.name as "Application/User/@name",
				u.startup_value as "Application/User/@startupValue",
				isnull(u.li_picture, fb_picture) as "Application/User/@picture"
				from application a
				join [user]	u
					on u.id = a.[user_id]
				join round_need rn
					on  a.round_need_id = rn.id
				join [round] r
					on r.id = rn.round_id
				join company c
					on c.id = r.company_id 
			where a.id = @application_id 
			for xml path  ('Item')
			)

return @item 

end

GO
/****** Object:  UserDefinedFunction [dbo].[fn_activ_company_approval]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_activ_company_approval](@company_id int)
returns xml
as
begin 

declare @item   xml

set @item =(
			select 'WAITING_FOR_APROVAL' as "@type",
			c.created as "@created",
			c.name as "Company/@name",
			c.slug as "Company/@slug",
			c.token as "Company/@token",
			c.logo as "Company/@logo",
			t.name as "Company/@roundTemplateName"
			from company c
			join round r
				on r.company_id = c.id
			join template t
				on t.id = r.template_id 
			where c.id = @company_id 
			for xml path  ('Item')
			)

return @item 

end




GO
/****** Object:  UserDefinedFunction [dbo].[fn_activ_company_publish]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_activ_company_publish](@company_id int)
returns xml
as
begin 

declare @item   xml

set @item =(
			select 'PUBLISHED' as "@type",
			c.created as "@created",
			c.name as "Company/@name",
			c.slug as "Company/@slug",
			c.token as "Company/@token",
			c.logo as "Company/@logo",
			(
				select u.token as "@token",
				u.slug as "@slug",
						email as "@email",
						headline as "@headline",
						u.name as "@name",
						u.startup_value as "@startupValue",
						isnull(u.li_picture, fb_picture) as "@picture"
				from user_company uc
				join dbo.[user] u
					on u.id = uc.[user_id]
				join role r
					on r.id = uc.role_id
				where company_id = c.id
				and r.name = 'MENTOR'
				for xml path ('Mentors'), type
			)as "Company"
			from company c
			where c.id = @company_id 
			for xml path  ('Item'), type
			)

return @item 

end



GO
/****** Object:  UserDefinedFunction [dbo].[fn_activ_company_setup]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_activ_company_setup](@company_id int)
returns xml
as
begin 

declare @item   xml

set @item =(
			select 'COMPANY_SETUP' as "@type",
			c.created as "@created",
			c.name as "Company/@name",
			c.slug as "Company/@slug",
			c.token as "Company/@token",
			c.logo as "Company/@logo",
			x.token as "Company/User/@token",
			x.slug as "Company/User/@slug",
			x.email as "Company/User/@email",
			x.headline as "Company/User/@headline",
			x.name as "Company/User/@name",
			x.startup_value as "Company/User/@startupValue",
			x.picture as "Company/User/@picture"
			 from company c
			cross join (
				select top 1 u.token ,
							email ,
							headline ,
							u.name,
							u.startup_value,
							u.slug,
							isnull(u.li_picture, fb_picture) as picture
				from user_company uc
				join [user] u
					on u.id = uc.[user_id]
				where uc.company_id = @company_id
				order by uc.created asc
				)x

			where c.id = @company_id 
			for xml path  ('Item')
			)

return @item 

end
GO
/****** Object:  UserDefinedFunction [dbo].[fn_activ_endorsement]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create function [dbo].[fn_activ_endorsement](@endorsement_id int)
returns xml
as
begin 

declare @item   xml

set @item =(
			select 'ENDORSEMENT' as "@type",
						rne.created as "@created",
				u2.name as "Endorsement/@endorserName",
				u2.picture as "Endorsement/@endorserPicture",
				u2.token as "Endorsement/@endorserToken",
				u2.headline as "Endorsement/@endorserHeadline",
				rne.endorsee_name as "Endorsement/@endorseeName",
				rne.endorsee_linkedin_id as "Endorsement/@endorseeLinkedinId",
				rne.endorsee_headline as "Endorsement/@endorseeHeadline",
				rne.endorsee_picture as "Endorsement/@endorseePicture",
				rne.endorsee_skills as "Endorsement/@endorseeSkills",
				rn.name as "Endorsement/@needName",
				rn.slug as "Endorsement/@needSlug",
				c.name as "Endorsement/@companyName",
				c.slug as "Endorsement/@companySlug"
				from round_need_endorsement rne
				join round_need rn
					on rn.id = rne.round_need_id
				join dbo.[round] r
					on r.id = rn.round_id
				join company c 
					on c.id = r.company_id
				join [user] u2
					on u2.id = rne.endorser_id
				where rne.id =  @endorsement_id
			for xml path  ('Item')
			)

return @item 

end



GO
/****** Object:  UserDefinedFunction [dbo].[fn_activ_new_mentor]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_activ_new_mentor](@user_company_id int)
returns xml
as
begin 

declare @item   xml

set @item =(
			select 'MENTOR_ACCEPT' as "@type",
			uc.created as "@created",
			u.token as "User/@token",
				u.slug as "User/@slug",
			email as "User/@email",
			headline as "User/@headline",
			u.name as "User/@name",
			u.startup_value as "User/@startupValue"
			from user_company uc
			join [user] u
				on u.id = uc.[user_id]
			where uc.id = @user_company_id 
			for xml path  ('Item'), type
			)

return @item 

end


GO
/****** Object:  UserDefinedFunction [dbo].[fn_activ_new_mentor_invite]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_activ_new_mentor_invite](@invite_id int)
returns xml
as
begin 

declare @item   xml

set @item =(
			select 'MENTOR_INVITE' as "@type",
			i.created as "@created",
			i.name as "User/@name",
			u.token as "User/@token",
			u.email as "User/@email",
			u.headline as "User/@headline",
			u.startup_value as "User/@startupValue",
					u.slug as "User/@slug",
			isnull(u.li_picture, u.fb_picture) as "User/@picture",
			ui.name as "Invitor/@name",
			ui.token as "Invitor/@token",
			ui.slug as "Invitor/@slug",
			ui.email as "Invitor/@email",
			ui.headline as "Invitor/@headline",
			ui.startup_value as "Invitor/@startupValue",
			isnull(ui.li_picture, ui.fb_picture) as "Invitor/@picture"
			from invite i
			join [user] ui
				on ui.id = i.invitor_id
			left join [user] u
				on u.token = i.user_token
			where i.id = @invite_id
			for xml path  ('Item'), type
			)

return @item 

end

GO
/****** Object:  UserDefinedFunction [dbo].[fn_activ_new_team_member]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_activ_new_team_member](@user_company_id int)
returns xml
as
begin 

declare @item   xml

set @item =(
			select 'TEAM_MEMBER_ACCEPT' as "@type",
			uc.created as "@created",
			u.token as "User/@token",
			email as "User/@email",
			headline as "User/@headline",
			u.name as "User/@name",
			u.startup_value as "User/@startupValue",
					u.slug as "User/@slug"
			from user_company uc
			join [user] u
				on u.id = uc.[user_id]
			where uc.id = @user_company_id 
			for xml path  ('Item'), type
			)

return @item 

end


GO
/****** Object:  UserDefinedFunction [dbo].[fn_activ_new_team_member_invite]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_activ_new_team_member_invite](@invite_id int)
returns xml
as
begin 

declare @item   xml

set @item =(
			select 'TEAM_MEMBER_INVITE' as "@type",
			i.created as "@created",
			i.name as "User/@name",
			ui.name as "Invitor/@name",
			ui.slug as "Invitor/@slug",
			ui.token as "Invitor/@token",
			ui.email as "Invitor/@email",
			ui.headline as "Invitor/@headline",
			ui.startup_value as "Invitor/@startupValue",
			isnull(ui.li_picture, ui.fb_picture) as "Invitor/@picture"
			from invite i
			join [user] ui
				on ui.id = i.invitor_id
			where i.id = @invite_id
			for xml path  ('Item'), type
			)

return @item 

end


GO
/****** Object:  UserDefinedFunction [dbo].[fn_activ_pledge]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_activ_pledge](@pledge_id int)
returns xml
as
begin 

declare @item   xml

set @item =(
			select 'PLEDGE' as "@type",
				p.created as "@created",
				p.name as "Pledge/@name",
				network as "Pledge/@network",
				network_id as "Pledge/@networkId",
				picture as "Pledge/@picture",
				p.comment as "Pledge/@comment",
				o.token as "Pledge/@offerToken",
				o.name as "Pledge/@offerName",
				c.slug as "Pledge/@companySlug"
				from pledge p
				join offer o
					on o.id = p.offer_id
				join round r
					on r.id = o.product_id
				join company c
					on c.id = r.company_id
				where p.id = @pledge_id
				for xml path  ('Item')
			)

return @item 

end




GO
/****** Object:  UserDefinedFunction [dbo].[fn_create_key]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_create_key](@name nvarchar(255))
returns nvarchar(255)
as 
begin 

return upper(replace(replace(replace(replace(@name, ',' , '_'), '&' , '_'), '/' , '_'), ' ' , '_'))



end 

GO
/****** Object:  UserDefinedFunction [dbo].[fn_create_slug]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_create_slug](@name nvarchar(255))
returns nvarchar(255)
as
begin 
    declare @keepvalues as varchar(50) = '%[^a-z]%'
    while patindex(@keepvalues, @name) > 0
        set @name = stuff(@name, patindex(@keepvalues, @name), 1, '')

    return lower(@name)

end

GO
/****** Object:  UserDefinedFunction [dbo].[fn_create_user_slug]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_create_user_slug](@name nvarchar(255))
returns nvarchar(255)
as
begin 
declare @dup int

select @name = replace(rtrim(ltrim(@name)), ' ', '.')

if exists (select 1 
			from [user]
			where slug = @name
			)
set @dup = 1
while @dup > 0
begin 
if not exists (select 1 from [user] where slug = @name  + cast(@dup as varchar(25)))
select @name = @name  + cast(@dup as varchar(25)), @dup = 0
else
set @dup = @dup + 1
end 

return @name 

end 
GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_companies]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_get_companies](@company_id int)
returns xml
as
begin 

	declare  @company xml
				
	set @company = (
					select c.name as "@name",
					c.token as "@token", 
					c.slug as "@slug",
					c.description as "@description",
					c.angel_list_id as "@angelListId",
					c.angel_list_token as "@angelListToken",
					logo as "@logo",
					url as "@url",
					tag_string  as"@tagString",
					cr.name as "@currency",
						(
						select x.name as "@name",
						x.picture as "@picture",
						x.unconfirmed  as "@unconfirmed",
						x.token as "@token",
						headline as "@headline",
						x.role as "@role",
						x.email as "@email",
						x.startup_value as "@startupValue",
						x.slug as "@slug"
						from 
							(
							select u.name,
							isnull(u.li_picture, fb_picture) as picture, 0 as unconfirmed,
							token ,
							headline,	
							r.name as [role],
							email as email,
							u.startup_value ,
							slug
							from user_company uc
							join [user] u
								on u.id = uc.[user_id]
							join role r
								on r.id = uc.role_id
							where uc.company_id = @company_id
							union all
							select i.name,
							null , 1,
							null,
							null,
							r.name,
							null,
							0,
							null
							from invite i
							join role r
								on r.id = i.role_id
							where company_id = @company_id
							and confirmed = 0
							)x
						for xml path ('Users') , type
					),
					(
					select dbo.fn_get_round(id)
					from round r
					where r.company_id = c.id
					and finished is null
					)
					from company c
					join currency cr
						on cr.id = c.currency_id
					where c.id = @company_id 
					for xml path ('Companies'), type
					)

return  @company
end


GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_companies_mentor]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_get_companies_mentor](@user_id int)
returns xml
as
begin 

	declare  @company xml
				
	set @company = (
					select c.name as "@name",
					c.token as "@token", 
					c.slug as "@slug",
					c.description as "@description",
					c.angel_list_id as "@angelListId",
					c.angel_list_token as "@angelListToken",
					logo as "@logo",
					url as "@url",
					tag_string  as"@tagString"
					from company c
					join user_company uc
						on c.id = uc.company_id
					join role r
						on r.id = uc.role_id
					where uc.user_id = @user_id
					and r.name = 'MENTOR'
					for xml path ('Companies'), type
					)

return  @company
end


GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_company]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_get_company](@company_id int)
returns xml
as
begin 

	declare  @company xml
				
	set @company = (
					select c.name as "@name",
					c.token as "@token", 
					c.slug as "@slug",
					c.description as "@description",
					c.angel_list_id as "@angelListId",
					c.angel_list_token as "@angelListToken",
					logo as "@logo",
					url as "@url",
					tag_string  as"@tagString",
					c.pitch as "@pitch",
					c.slide_share as "@slideShare",
					c.video as "@video",
					cr.name as "@currency",
					(
					select url  as "@url"
					from company_picture cp
					where cp.company_id = c.id
					for xml path ('Pictures'), type
					),
					(
					select	value as "@text",
							u.name as "@userName",
							u.picture as "@userPicture",
							u.headline as"@userHeadline",
							u.token as "@userToken",
							u.slug as "@userSlug",
							cu.created as "@created"
					from company_update cu
					join [user] u
						on u.id = cu.[user_id]
					where cu.company_id = c.id
					for xml path ('Updates'), type
					),
					(
						select x.name as "@name",
						x.picture as "@picture",
						x.unconfirmed  as "@unconfirmed",
						x.token as "@token",
						headline as "@headline",
						x.role as "@role",
						x.email as "@email",
						x.startup_value as "@startupValue",
						x.slug as "@slug",
						x.invite_token as "@inviteToken"
						from 
							(
							select u.name,
							isnull(u.li_picture, fb_picture) as picture, 
							0 as unconfirmed,
							token ,
							headline,	
							r.name as [role],
							email as email,
							u.startup_value ,
							u.slug ,
							null as invite_token
							from user_company uc
							join [user] u
								on u.id = uc.[user_id]
							join role r
								on r.id = uc.role_id
							where uc.company_id = @company_id
							union all
							select i.name,
							u.picture,
							1,
							u.token,
							u.headline,
							r.name,
							u.email,
							isnull(u.startup_value ,0),
							null,
							i.token
							from invite i
							left join [user] u
								on u.token = i.user_token 
							join role r
								on r.id = i.role_id
							where company_id = @company_id
							and confirmed = 0
							)x
						for xml path ('Users') , type
					),
					(
					select dbo.fn_get_round(id)
					from round r
					where r.company_id = c.id
					and finished is null
					)
					from company c
					join currency cr
						on cr.id=c.currency_id
					where c.id = @company_id 
					for xml path ('Company'), type
					)

return  @company
end


GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_company_value]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_get_company_value](@company_id int)
returns int
as
begin 

	declare  @company int
				
	select @company = sum (u.startup_value)
	from user_company us
	join [user] u 
		on us.user_id = u.id
	where us.company_id=@company_id

return  @company
end

GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_md5_hash]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_get_md5_hash](@string varchar(4000))
returns char(32)
as
begin

	declare @return char(32)
	
	select @return = lower(convert(varchar(max),hashbytes('md5',@string),2))

	return @return
end



GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_need]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE function [dbo].[fn_get_need](@need_id int)
		returns xml
		as
		begin 

		declare @need xml
		set @need = (
						select n.name as "@name",
						n.[key] as "@key",
						n.[description] as "@description",
						n.summary as "@summary",
						c.name as "@category",
						(
								select name as "@name",
										[description] as "@description"
								from need_tag nt
								join tag t
									on t.id = nt.tag_id
								where nt.need_id = n.id
								for xml path ('Tags'), type
							),
						(
								select s.name as "@name",
									s.url as "@url",
									s.logo as "@logo"
								from service_need sn
								join [service] s
									on s.id = sn.service_id
								where sn.need_id = n.id
								for xml path ('Services'), type
							)
						from need n							
						join category c
							on  c.id = n.category_id
						where n.id=@need_id					
						for xml path ('Need'), type		
					)

		return @need
		end 

GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_round]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_get_round](@round_id int)
returns xml 
as
begin 
declare @round xml


set @round = (
					select r.start as "@start",
					r.token as "@token",
					case when r.published is not null then 'PUBLISHED' else 'PENDING' end as "@status",
					[dbo].[fn_round_workflow](r.id),
					(
					
						select funding as "@amount",
							valuation as "@valuation",
							funding_description as "@description",
							funding_contract as "@contract",
							(
								select i.amount as "@amount",
								i.created as "@created",
									u.name as "User/@name",
									u.token as "User/@token",
									u.slug as "User/@slug",
									u.picture as "User/@picture",
									u.headline as "User/@headline"
								from investment i
								join [user] u
									on u.[id] = i.[user_id]
								where i.round_id = r2.id
								for xml path ('Investments'), type
							)
						from round r2
						where r2.id  = r.id
						for xml path ('Funding') , type
					
					),
						(
						select p.name as "@name",
								p.[description] as "@description",
								p.token as "@token",
								video as "@video",
								picture as "@picture",
								(
								select o.description as "@description",
								o.stock - isnull(x.no,0) as "@stock",
								o.price as "@price",
								created as "@created",
								o.name as "@name",
								o.token as "@token"
								from offer o
								left join (
											select count(*) no, offer_id
											from pledge pl
											group by offer_id
											)x
										on x.offer_id = o.id
								where o.product_id = p.id
								for xml path ('Offers'), type
								),
									(
									select url  as "@url"
									from product_picture pp
									where pp.product_id = p.id
									for xml path ('Pictures'), type
									)
						from product p
						where p.id = r.id
						for xml path ('Product'), type
					),
					t.name as "Template/@name",
					t.[key] as "Template/@key",
					t.picture as "Template/@picture",
					t.logo as "Template/@logo",
							(
							select rn.name as "@name",
							rn.slug as "@slug",
							[key] as "@key",
							rn.token as "@token",
							rn.customtext as "@customText",
							n.summary as "@summary",
							st.name as "@status",
							c.name as "@category",
							expert as "@isExpert",
							rn.picture as "@picture",
							n.description as "@description",
							rn.cash as "@cash",
							rn.equity  as "@equity",
							(
								select message as "@message",
										created as "@created",
										token as "@token",
										case when approved is not null then 1 else 0 end as "@approved",
								(
									select picture as "@picture",
											name as "@name",
											token as "@token",
											headline as "@headline",
											u.slug as "@slug"
									from [user] u
									where u.id = a.[user_id]
									for xml path ('User'), type
								)
								from application a
								where rn.id = a.round_need_id
								for xml path ('Applications'), type
							),
							(
								select name as "@name",
										[description] as "@description"
								from round_need_tag rnt
								join tag t
									on t.id = rnt.tag_id
								where rnt.round_need_id = rn.id
								for xml path ('Tags'), type
							),
							(
								select distinct s.name as "@name",
												s.url as "@url",
												s.worker as "@worker",
												s.picture as "@picture",
												s.logo as "@logo"
								from service_need srn
								join round_need rn2
									on rn2.need_id = srn.need_id
								join v_service s
									on srn.service_id = s.id
								where rn2.id = rn.id
								for xml path ('Services'), type
								),
								(
									select distinct expert_first_name  as "@firstName",
											expert_last_name as "@lastName", 
											expert_picture as "@picture", 
											expert_id as "@linkedinId", 
											expert_headline as "@headline",
											intro_first_name as "@introFirstName", 
											intro_last_name as "@introLastName", 
											intro_picture as "@introPicture", 
											intro_id as "@introLinkedinId"
									from expert_round_need ern
									where ern.round_need_id = rn.id
									for xml path ('Experts'), type
								),

										(
									select u2.name as "@endorserName",
									u2.picture as "@endorserPicture",
									u2.token as "@endorserToken",
									u2.slug as "@endorserSlug",
									u2.headline as "@endorserHeadline",
									rne.endorsee_name as "@endorseeName",
									rne.endorsee_linkedin_id as "@endorseeLinkedinId",
									rne.endorsee_headline as "@endorseeHeadline",
									rne.endorsee_picture as "@endorseePicture",
									rne.endorsee_skills as "@endorseeSkills",
									rn.name as "@needName",
									rn.slug as "@needSlug",
									c.name as "@companyName",
									c.slug as "@companySlug",
									rne.created as "@created"
									from round_need_endorsement rne
									join round_need rn2
										on rn2.id = rne.round_need_id
									join dbo.[round] r
										on r.id = rn.round_id
									join company c 
										on c.id = r.company_id
									join [user] u2
										on u2.id = rne.endorser_id
									where rn2.id = rn.id
									for xml path ('Endorsements'), type
								)
							from round_need rn
							join status st
								on st.id = rn.status_id
							join need n			
								on n.id = rn.need_id
							join category c
								on c.id = n.category_id
							left join v_service s
								on s.id = rn.service_id
							where r.id = rn.round_id

							for xml path ('Needs') ,type		
							),
							(
								select u.token, 
									u.name,
									u.email,
									u.slug,
									(
									select li_access_token  as "@accessToken",
											li_secret as "@secret",
											linkedin_id as "@id",
											'LI' as "@type"
									from [user] u1
									where u.id = u1.id
									for xml path ('Profile'), type
									)
								from company c
								join [user_company] uc
									on c.id = uc.company_id
								join [user] u
									on u.id = uc.[user_id]
								where r.company_id = c.id
								for xml path ('Users') , type
							),
							(
								select p.name as "@name",
								network as "@network",
								network_id as "@networkId",
								picture as "@picture",
								p.comment as "@comment",
								o.token as "@offerToken",
								o.name as "@offerName",
								p.created as "@created"
								from pledge p
								join offer o
									on o.id = p.offer_id
								where o.product_id = r.id
								for xml path ('Pledges'), type
							)

					from round r
					join template t
						on t.id = r.template_id 
					where r.id = @round_id
					for xml path ('Round'), type
				)

return @round

end 


GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_service]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		create function [dbo].[fn_get_service](@service_id int)
		returns xml
		as
		begin 

		declare @service xml
		set @service = (
					select name as "@name",
						   url as "@url",
						   logo as "@logo"
					from [service]
					where id = @service_id
					for xml path ('Service'), type
					)

		return @service
		end 

GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_startup_value]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_get_startup_value](@user_id int)
returns int
as
begin

	declare @return int

	select @return = isnull(linkedin_value,0) + isnull(fb_value,0) + isnull(xing_value,0)
	from [user]
	where id = @user_id

	return @return
end



GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_template]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE function [dbo].[fn_get_template](@template_id int)
		returns xml
		as
		begin 

		declare @template xml
		set @template = (
						select name as "@name",
							[key] as "@key",
							[description] as "@description",
							active as "@active",
							picture as "@picture",
							logo as "@logo",
					(
						select n.name as "@name",
						n.[key] as "@key",
						n.[description] as "@description",
						n.summary as "@summary",
						c.name as "@category",
						(
								select name as "@name",
										[description] as "@description"
								from need_tag nt
								join tag t
									on t.id = nt.tag_id
								where nt.need_id = n.id
								for xml path ('Tags'), type
							)
						from template_need tn
						join need n
							on n.id = tn.need_id
						join category c
							on  c.id = n.category_id
						where tn.template_id = t.id
						for xml path ('Need'), type
					)
					from template t
					where id = @template_id
					for xml path ('Template'), type
					)

		return @template
		end 

GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_user_base]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE function [dbo].[fn_get_user_base](@user_id int)
		returns xml
		as
		begin 

		declare @newest_company int 
		select @newest_company = max(company_id) from user_company where [user_id] = @user_id

		declare @user xml, @company xml, @company_id int
		set @user = (
						select 
							u.token as "@token",
							email as "@email",
							headline as "@headline",
							u.name as "@name",
							u.startup_value as "@startupValue",
							u.slug as "@slug",						
							isnull(u.li_picture, fb_picture) as "@picture",													
							u.interests as "@interests",
							u.investment_amount as "@investmentAmount",
							cur.name as "@currency",	
							u.fb_link as "@fbLink",
							u.xing_link as "@xingLink",																	
							(
								select name as "@name"
								from skill s
								left join user_skill us
									on us.skill_id = s.id
								left join user_custom_skill ucs
									on ucs.skill_id = s.id
								where us.[user_id] = u.id
								or ucs.[user_id]= u.id
								for xml path ('Skills'), type
							),
							(
								select ro.name as "@name"
								from [role] ro
								join user_role ur
									on ur.[role_id] = ro.id
								where ur.[user_id] = u.id
								for xml path ('Roles'), type
							),
							dbo.get_user_applications(u.id), 
							dbo.fn_get_company(@newest_company),

							(
								select dbo.fn_get_companies(uc.company_id)
								from user_company uc
								where uc.[user_id] = u.id
								for xml path (''), type

							),
							(
								select fb_access_token  as "@accessToken",
										facebook_id as "@id",
										'FB' as "@type",
										fb_picture as "@picture"
								from [user] u1
								where u.id = u1.id
								for xml path ('Profile'), type
							),
								(
								select li_access_token  as "@accessToken",
										linkedin_id as "@id",
										'LI' as "@type",
										li_picture as "@picture"
								from [user] u1
								where u.id = u1.id
								for xml path ('Profile'), type
							),
							
									(
									select u2.name as "@endorserName",
									u2.picture as "@endorserPicture",
									u2.token as "@endorserToken",
									u2.slug as "@endorserSlug",
									u2.headline as "@endorserHeadline",
									rne.endorsee_name as "@endorseeName",
									rne.endorsee_linkedin_id as "@endorseeLinkedinId",
									rne.endorsee_headline as "@endorseeHeadline",
									rne.endorsee_picture as "@endorseePicture",
									rne.endorsee_skills as "@endorseeSkills",
									rn.name as "@needName",
									rn.slug as "@needSlug",
									c.name as "@companyName",
									c.slug as "@companySlug",
									rne.created as "@created"
									from round_need_endorsement rne
									join round_need rn
										on rn.id = rne.round_need_id
									join dbo.[round] r
										on r.id = rn.round_id
									join company c 
										on c.id = r.company_id
									join [user] u2
										on u2.id = rne.endorser_id
									where u.linkedin_id = endorsee_linkedin_id
									for xml path ('Endorsements'), type
								)
						from [user] u					
						left join currency cur
							on cur.id = u.currency_id
						where u.id = @user_id
						for xml path ('User'), type 
					)

		return @user
		end 

GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_user_mini]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

		CREATE function [dbo].[fn_get_user_mini](@user_id int)
		returns xml
		as
		begin 

		declare @user xml, @company xml, @company_id int
		set @user = (
						select 
							u.token as "@token",
							email as "@email",
							headline as "@headline",
							u.name as "@name",
							u.startup_value as "@startupValue",
							isnull(u.li_picture, fb_picture) as "@picture",
							u.slug as "@slug",
							u.interests as "@interests",
							u.fb_link as "@fbLink",
							u.xing_link as "@xingLink",	
							[dbo].[fn_get_companies_mentor](u.id)
						from [user] u					
						where u.id = @user_id
						for xml path ('User'), type 
					)

		return @user
		end 

GO
/****** Object:  UserDefinedFunction [dbo].[fn_round_workflow]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_round_workflow](@round_id int)
returns xml
as
begin
declare @workflow xml
set @workflow = (	
						select w.name as "@name", enforce_order as "@enforceOrder",
								(	
									select s.name as "@name",
											s.[order] as "@order",
											s.skippable as "@skippable",
											[dbo].[fn_round_workflow_stage](@round_id, s.id) as "@completed"
									from dbo.stage s
									where w.id = s.workflow_id
									for xml path ('Stage'), type
								)
							from workflow w
							for xml path ('Workflow'), type
						)
return @workflow


end

GO
/****** Object:  UserDefinedFunction [dbo].[fn_round_workflow_stage]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_round_workflow_stage](@round_id int, @stage_id int)
Returns bit
as
begin
declare @completed bit

declare @stage varchar(255), @company_id int
select @stage = name from stage where id  = @stage_id

select @company_id = company_id from [round] r where r.id = @round_id

if @stage = 'CREATE_COMPANY'
begin
	if exists (
				select 1 from company where id  = @company_id
				)
	set @completed = 1
	else 
	set @completed = 0
end

if @stage = 'ADD_MENTOR'
begin
	if exists (
				select 1 
				from invite i
				join [role] r
					on r.id = i.role_id
				where company_id = @company_id
				and r.name = 'MENTOR'
				)
	set @completed = 1
	else 
	set @completed = 0
end



if @stage = 'INVITE_TEAM'
begin
	if exists (
				select 1 
				from invite i
				join [role] r
					on r.id = i.role_id
				where company_id = @company_id
				and r.name != 'MENTOR'
				)
	set @completed = 1
	else 
	set @completed = 0
end

if @stage = 'CREATE_PRODUCT'
begin 
	if exists (
				select 1 
				from  [round] r
				join product p
					on p.id = r.id
				join offer o
					on o.product_id = p.id
				where r.id = @round_id
				)
	set @completed = 1
	else 
	set @completed = 0

end

if @stage = 'CUSTOMISE_NEEDS'
begin 
	
		if  exists (
				select 1 
				from  [round_need] rn
				join status  s
					on s.id = rn.status_id
				where rn.round_id = @round_id
				and s.name in ('ADDED', 'CUSTOMISED')
				)
	set @completed = 1
	else 
	set @completed = 0
end




if @stage = 'SENT_FOR_MENTOR_APRROVAL'
begin 
	
		if  exists (
				select 1 
				from  [round] r
				where r.id = @round_id
				and sent_to_mentor is not null
				)
	set @completed = 1
	else 
	set @completed = 0
end



if @stage = 'PUBLISH'
begin 
	if exists (select 1 
				from round r
				where @round_id = r.id
				and published is not null
				
				
				)
				
	set @completed = 1
	else 
	set @completed = 0 
end


if @stage = 'FUNDING'
begin 
	if exists (select 1 
				from round r
				where @round_id = r.id
				and funding is not null
				
				
				)
				
	set @completed = 1
	else 
	set @completed = 0 
end

return isnull(@completed, 0)
end


GO
/****** Object:  UserDefinedFunction [dbo].[get_round_need]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[get_round_need](@round_need_id int)
returns xml
as
begin 

declare @need xml
set @need = 
		(
							select rn.name as "@name",
							[key] as "@key",
							rn.token as "@token",
							st.name as "@status",
							c.name as "@category",
							expert as "@isExpert",
							rn.picture as "@picture",
							rn. slug as "@slug",
						--	n.description as "@description",
							rn.customText as "@customText",
							n.summary as "@summary",
							rn.cash as "@cash",
							rn.equity  as "@equity",
							(
								select message as "@message",
										created as "@created",
								(
									select picture as "@picture",
											name as "@name",
											token as "@token"
									from [user] u
									where u.id = a.[user_id]
									for xml path ('User'), type
								)
								from application a
								where rn.id = a.round_need_id
								for xml path ('Applications'), type
							),
							(
								select name as "@name",
										[description] as "@description"
								from round_need_tag rnt
								join tag t
									on t.id = rnt.tag_id
								where rnt.round_need_id = rn.id
								for xml path ('Tags'), type
							),
							(
								select distinct s.name as "@name",
										s.url as "@url",
										s.worker as "@worker",
										s.picture as "@picture",
										s.logo as "@logo"
								from service_round_need srn
								join v_service s
									on srn.service_id = s.id
								where srn.round_need_id = rn.id
								for xml path ('Services'), type
								),
								(
									select expert_first_name  as "@firstName",
											expert_last_name as "@lastName", 
											expert_picture as "@picture", 
											expert_id as "@linkedinId", 
											intro_first_name as "@introFirstName", 
											intro_last_name as "@introLastName", 
											intro_picture as "@introPicture", 
											intro_id as "@introLinkedinId"
									from expert_round_need ern
									where ern.round_need_id = rn.id
									for xml path ('Experts'), type
								),
								[dbo].[fn_get_company](r.company_id)
							from round_need rn
							join round r
								on r.id = rn.round_id
							join status st
								on st.id = rn.status_id
							join need n			
								on n.id = rn.need_id
							join category c
								on c.id = n.category_id
							left join v_service s
								on s.id = rn.service_id
							where rn.id = @round_need_id
							for xml path ('Needs') ,type		
							)
return @need
end 


GO
/****** Object:  UserDefinedFunction [dbo].[get_user_applications]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[get_user_applications](@user_id int)
returns xml
as
begin 

declare @application xml

set @application = (
				select a.message as "@message",
						a.created as "@created",
						logo as "@comapnyLogo",
						c.name as "@companyName",
						c.token as "@companyToken", 
						c.slug as "@companySlug",
						rn.name as "@need",
						rn.token as "@needToken",
						rn.slug as "@needSlug"
						from application a
						join round_need rn
							on  a.round_need_id = rn.id
						join [round] r
							on r.id = rn.round_id
						join company c
							on c.id = r.company_id 
						where a.[user_id] =  @user_id 
						for xml path ('Applications'), type
					)

return @application
end

GO
/****** Object:  Table [dbo].[service]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[service](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[url] [nvarchar](1024) NOT NULL,
	[created] [datetime] NOT NULL,
	[logo] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[url] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[worker]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[worker](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[picture] [varchar](255) NULL,
	[created] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[worker_service]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[worker_service](
	[worker_id] [int] NOT NULL,
	[service_id] [int] NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [pk_worker_service] PRIMARY KEY CLUSTERED 
(
	[worker_id] ASC,
	[service_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[v_service]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[v_service]
as
select s.name, s.id,s.url, max( w.name) worker, max(picture) picture, s.logo
from dbo.[service] s
join dbo.worker_service ws
	on ws.service_id = s.id
join worker w
	on w.id = ws.worker_id
group by s.name, s.id, s.url, s.logo


GO
/****** Object:  Table [dbo].[company]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[company](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NULL,
	[created] [datetime] NOT NULL,
	[token] [char](36) NOT NULL,
	[description] [varchar](max) NULL,
	[angel_list_id] [nvarchar](255) NULL,
	[slug] [nvarchar](255) NOT NULL,
	[angel_list_token] [nvarchar](255) NULL,
	[url] [nvarchar](255) NULL,
	[logo] [nvarchar](255) NULL,
	[tag_string] [varchar](255) NULL,
	[pitch] [nvarchar](4000) NULL,
	[slide_share] [nvarchar](1024) NULL,
	[video] [nvarchar](255) NULL,
	[currency_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[token] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[user]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[user](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[token] [char](36) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[fb_access_token] [nvarchar](255) NULL,
	[li_access_token] [nvarchar](255) NULL,
	[created] [datetime] NOT NULL,
	[email] [nvarchar](255) NOT NULL,
	[pwd] [nvarchar](255) NULL,
	[facebook_id] [bigint] NULL,
	[gender] [char](1) NULL,
	[dob] [datetime] NULL,
	[fb_picture] [varchar](255) NULL,
	[linkedin_id] [nvarchar](255) NULL,
	[li_picture] [varchar](255) NULL,
	[li_secret] [nvarchar](255) NULL,
	[picture]  AS (isnull([li_picture],[fb_picture])),
	[headline] [nvarchar](255) NULL,
	[linkedin_value] [int] NULL,
	[slug] [nvarchar](255) NOT NULL,
	[interests] [nvarchar](max) NULL,
	[currency_id] [int] NULL,
	[investment_amount] [float] NULL,
	[fb_value] [int] NULL,
	[xing_value] [int] NULL,
	[startup_value]  AS ([dbo].[fn_get_startup_value]([id])),
	[fb_link] [nvarchar](255) NULL,
	[xing_link] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[v_slug]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[v_slug] WITH SCHEMABINDING 
as
select slug, 'USER' as type
from dbo.[user]
union all
select slug, 'COMPANY'
from dbo.company

GO
/****** Object:  UserDefinedFunction [dbo].[fn_promote_message_ref]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[fn_promote_message_ref](@xml xml)
RETURNS NVARCHAR(255)
with schemabinding 
AS
BEGIN
DECLARE @ref NVARCHAR(255)

SELECT @ref =  @xml.value('(/Message/@id)[1]', 'NVARCHAR(255)')

RETURN @ref

END 

GO
/****** Object:  Table [dbo].[message_queue]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[message_queue](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[message] [xml] NOT NULL,
	[retry] [int] NOT NULL,
	[ref]  AS ([dbo].[fn_promote_message_ref]([message])),
	[status_id] [int] NOT NULL,
	[created] [datetime] NOT NULL,
	[fetched] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[activity]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[activity](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[item] [xml] NOT NULL,
	[round_id] [int] NOT NULL,
	[created] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[application]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[application](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[message] [nvarchar](max) NOT NULL,
	[round_need_id] [int] NOT NULL,
	[created] [datetime] NOT NULL,
	[approved] [datetime] NULL,
	[token] [char](36) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[category]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[category](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](25) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[company_picture]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[company_picture](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[url] [nvarchar](255) NOT NULL,
	[company_id] [int] NOT NULL,
	[created] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[company_template]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[company_template](
	[company_id] [int] NOT NULL,
	[template_id] [int] NOT NULL,
	[created] [datetime] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[company_update]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[company_update](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[value] [nvarchar](max) NOT NULL,
	[user_id] [int] NULL,
	[created] [datetime] NOT NULL,
	[company_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[content]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[content](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[static] [xml] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[currency]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[currency](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [char](3) NOT NULL,
	[created] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ__currency__name__2143AFDF] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[edge]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[edge](
	[user_linkedin_id] [nvarchar](255) NOT NULL,
	[user_connection] [nvarchar](255) NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [pk_user_connection] PRIMARY KEY CLUSTERED 
(
	[user_linkedin_id] ASC,
	[user_connection] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[errors]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[errors](
	[de_id] [bigint] IDENTITY(1,1) NOT NULL,
	[de_error_number] [int] NULL,
	[de_error_severity] [int] NULL,
	[de_error_state] [int] NULL,
	[de_error_procedure] [varchar](100) NULL,
	[de_error_params] [xml] NULL,
	[de_error_line] [int] NULL,
	[de_error_message] [varchar](max) NULL,
	[de_error_date] [datetime] NULL,
	[de_login] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[de_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[expert_round_need]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[expert_round_need](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[round_need_id] [int] NOT NULL,
	[expert_first_name] [nvarchar](255) NULL,
	[expert_last_name] [nvarchar](255) NULL,
	[expert_picture] [varchar](255) NULL,
	[expert_id] [varchar](255) NULL,
	[intro_first_name] [nvarchar](255) NULL,
	[intro_last_name] [nvarchar](255) NULL,
	[intro_picture] [varchar](255) NULL,
	[intro_id] [varchar](255) NULL,
	[created] [datetime] NOT NULL,
	[expert_headline] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[investment]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[investment](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[amount] [int] NOT NULL,
	[round_id] [int] NOT NULL,
	[user_id] [int] NOT NULL,
	[created] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[invite]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[invite](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[token] [char](36) NOT NULL,
	[email] [nvarchar](255) NOT NULL,
	[name] [nvarchar](255) NULL,
	[invitor_id] [int] NOT NULL,
	[company_id] [int] NULL,
	[confirmed] [bit] NOT NULL,
	[role_id] [int] NOT NULL,
	[user_token] [char](36) NULL,
	[created] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[token] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[message_status]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[message_status](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[need]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[need](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NULL,
	[created] [datetime] NOT NULL,
	[expert] [bit] NOT NULL,
	[key] [varchar](255) NULL,
	[category_id] [int] NOT NULL,
	[description] [nvarchar](max) NULL,
	[picture] [nvarchar](255) NULL,
	[summary] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[need_Tag]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[need_Tag](
	[need_id] [int] NOT NULL,
	[tag_id] [int] NOT NULL,
 CONSTRAINT [pk_need_Tag] PRIMARY KEY CLUSTERED 
(
	[need_id] ASC,
	[tag_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[offer]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[offer](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NOT NULL,
	[description] [nvarchar](max) NULL,
	[price] [int] NULL,
	[stock] [int] NULL,
	[created] [datetime] NOT NULL,
	[token] [char](36) NOT NULL,
	[name] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[pledge]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[pledge](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[picture] [nvarchar](255) NOT NULL,
	[network] [char](2) NOT NULL,
	[network_id] [nvarchar](255) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[offer_id] [int] NOT NULL,
	[comment] [nvarchar](max) NULL,
	[token] [char](36) NOT NULL,
	[created] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[product]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[product](
	[id] [int] NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[description] [nvarchar](max) NULL,
	[created] [datetime] NOT NULL,
	[picture] [nvarchar](255) NULL,
	[token] [char](36) NOT NULL,
	[video] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[product_picture]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[product_picture](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[product_id] [int] NOT NULL,
	[url] [nvarchar](1024) NOT NULL,
	[created] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[role]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[role](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[round]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[round](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[company_id] [int] NOT NULL,
	[start] [datetime] NOT NULL,
	[created] [datetime] NOT NULL,
	[token] [char](36) NOT NULL,
	[finished] [datetime] NULL,
	[template_id] [int] NULL,
	[published] [datetime] NULL,
	[sent_to_mentor] [datetime] NULL,
	[funding] [int] NULL,
	[valuation] [int] NULL,
	[funding_description] [nvarchar](max) NULL,
	[funding_contract] [nvarchar](1024) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[round_need]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[round_need](
	[round_id] [int] NOT NULL,
	[need_id] [int] NOT NULL,
	[created] [datetime] NOT NULL,
	[service_id] [int] NULL,
	[expert_first_name] [nvarchar](255) NULL,
	[expert_last_name] [nvarchar](255) NULL,
	[expert_picture] [varchar](255) NULL,
	[expert_id] [varchar](255) NULL,
	[intro_first_name] [nvarchar](255) NULL,
	[intro_last_name] [nvarchar](255) NULL,
	[intro_picture] [varchar](255) NULL,
	[intro_id] [varchar](255) NULL,
	[status_id] [int] NULL,
	[token] [char](36) NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NULL,
	[equity] [int] NULL,
	[cash] [int] NULL,
	[picture] [nvarchar](255) NULL,
	[customText] [nvarchar](max) NULL,
	[slug] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[round_need_endorsement]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[round_need_endorsement](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[round_need_id] [int] NOT NULL,
	[endorser_id] [int] NOT NULL,
	[endorsee_linkedin_id] [nvarchar](255) NOT NULL,
	[created] [datetime] NOT NULL,
	[endorsee_headline] [varchar](255) NULL,
	[endorsee_picture] [varchar](255) NULL,
	[endorsee_skills] [varchar](255) NULL,
	[endorsee_name] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[round_need_tag]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[round_need_tag](
	[round_need_id] [int] NOT NULL,
	[tag_id] [int] NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [pk_round_need_tag] PRIMARY KEY CLUSTERED 
(
	[round_need_id] ASC,
	[tag_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[service_import]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[service_import](
	[catogery] [varchar](500) NULL,
	[provider] [varchar](500) NULL,
	[language] [varchar](500) NULL,
	[url] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[service_need]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[service_need](
	[service_id] [int] NOT NULL,
	[need_id] [int] NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [pk_sevice_need] PRIMARY KEY CLUSTERED 
(
	[service_id] ASC,
	[need_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[service_round_need]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[service_round_need](
	[service_id] [int] NOT NULL,
	[round_need_id] [int] NOT NULL,
	[created] [datetime] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[setting]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[setting](
	[key] [varchar](255) NOT NULL,
	[value] [varchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[skill]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[skill](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[stage]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[stage](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](255) NOT NULL,
	[workflow_id] [int] NOT NULL,
	[order] [int] NULL,
	[skippable] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[status]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[status](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tag]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tag](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[description] [nvarchar](400) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Tally]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tally](
	[N] [int] NOT NULL,
 CONSTRAINT [PK_Tally_N] PRIMARY KEY CLUSTERED 
(
	[N] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[template]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[template](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[created] [datetime] NOT NULL,
	[key] [varchar](255) NULL,
	[description] [nvarchar](max) NULL,
	[picture] [varchar](255) NULL,
	[import_id] [int] NULL,
	[active] [bit] NOT NULL,
	[logo] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[template_need]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[template_need](
	[template_id] [int] NOT NULL,
	[need_id] [int] NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [pk_template_need] PRIMARY KEY CLUSTERED 
(
	[template_id] ASC,
	[need_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[testing]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[testing](
	[id] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[user_company]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[user_company](
	[user_id] [int] NOT NULL,
	[company_id] [int] NOT NULL,
	[created] [datetime] NOT NULL,
	[role_id] [int] NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [pk_user_company] PRIMARY KEY CLUSTERED 
(
	[user_id] ASC,
	[company_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[user_custom_skill]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[user_custom_skill](
	[user_id] [int] NOT NULL,
	[skill_id] [int] NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [pk_user_custom_skill] PRIMARY KEY CLUSTERED 
(
	[user_id] ASC,
	[skill_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[user_role]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[user_role](
	[user_id] [int] NOT NULL,
	[role_id] [int] NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [pk_user_type] PRIMARY KEY CLUSTERED 
(
	[user_id] ASC,
	[role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[user_skill]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[user_skill](
	[user_id] [int] NOT NULL,
	[skill_id] [int] NOT NULL,
	[created] [datetime] NOT NULL,
 CONSTRAINT [pk_user_skill] PRIMARY KEY CLUSTERED 
(
	[user_id] ASC,
	[skill_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[workflow]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[workflow](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[enforce_order] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[v_newid]    Script Date: 27.9.2013 12:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[v_newid]
as
select newid() as guid
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [company_name]    Script Date: 27.9.2013 12:57:46 ******/
CREATE NONCLUSTERED INDEX [company_name] ON [dbo].[company]
(
	[name] ASC
)
WHERE ([name] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [ix_company_slug]    Script Date: 27.9.2013 12:57:46 ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_company_slug] ON [dbo].[company]
(
	[slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[activity] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[application] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[application] ADD  DEFAULT (newid()) FOR [token]
GO
ALTER TABLE [dbo].[company] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[company_picture] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[company_template] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[company_update] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[currency] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[edge] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[investment] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[invite] ADD  DEFAULT ((0)) FOR [confirmed]
GO
ALTER TABLE [dbo].[invite] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[message_queue] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[need] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[need] ADD  DEFAULT ((0)) FOR [expert]
GO
ALTER TABLE [dbo].[offer] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[offer] ADD  DEFAULT (newid()) FOR [token]
GO
ALTER TABLE [dbo].[pledge] ADD  DEFAULT (newid()) FOR [token]
GO
ALTER TABLE [dbo].[pledge] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[product] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[product_picture] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[round] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[round_need] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[round_need_endorsement] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[round_need_tag] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[service] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[service_need] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[service_round_need] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[stage] ADD  DEFAULT ((0)) FOR [skippable]
GO
ALTER TABLE [dbo].[template] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[template] ADD  DEFAULT ((1)) FOR [active]
GO
ALTER TABLE [dbo].[template_need] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[user] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[user_company] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[user_company] ADD  DEFAULT ((1)) FOR [role_id]
GO
ALTER TABLE [dbo].[user_custom_skill] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[user_role] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[user_skill] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[worker] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[worker_service] ADD  DEFAULT (getutcdate()) FOR [created]
GO
ALTER TABLE [dbo].[activity]  WITH CHECK ADD FOREIGN KEY([round_id])
REFERENCES [dbo].[round] ([id])
GO
ALTER TABLE [dbo].[application]  WITH CHECK ADD FOREIGN KEY([round_need_id])
REFERENCES [dbo].[round_need] ([id])
GO
ALTER TABLE [dbo].[application]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[user] ([id])
GO
ALTER TABLE [dbo].[company]  WITH CHECK ADD FOREIGN KEY([currency_id])
REFERENCES [dbo].[currency] ([id])
GO
ALTER TABLE [dbo].[company_picture]  WITH CHECK ADD FOREIGN KEY([company_id])
REFERENCES [dbo].[company] ([id])
GO
ALTER TABLE [dbo].[company_template]  WITH CHECK ADD FOREIGN KEY([company_id])
REFERENCES [dbo].[company] ([id])
GO
ALTER TABLE [dbo].[company_template]  WITH CHECK ADD FOREIGN KEY([template_id])
REFERENCES [dbo].[template] ([id])
GO
ALTER TABLE [dbo].[company_update]  WITH CHECK ADD FOREIGN KEY([company_id])
REFERENCES [dbo].[company] ([id])
GO
ALTER TABLE [dbo].[company_update]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[user] ([id])
GO
ALTER TABLE [dbo].[expert_round_need]  WITH CHECK ADD FOREIGN KEY([round_need_id])
REFERENCES [dbo].[round_need] ([id])
GO
ALTER TABLE [dbo].[investment]  WITH CHECK ADD FOREIGN KEY([round_id])
REFERENCES [dbo].[round] ([id])
GO
ALTER TABLE [dbo].[investment]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[user] ([id])
GO
ALTER TABLE [dbo].[invite]  WITH CHECK ADD FOREIGN KEY([company_id])
REFERENCES [dbo].[company] ([id])
GO
ALTER TABLE [dbo].[invite]  WITH CHECK ADD FOREIGN KEY([invitor_id])
REFERENCES [dbo].[user] ([id])
GO
ALTER TABLE [dbo].[invite]  WITH CHECK ADD FOREIGN KEY([role_id])
REFERENCES [dbo].[role] ([id])
GO
ALTER TABLE [dbo].[message_queue]  WITH CHECK ADD FOREIGN KEY([status_id])
REFERENCES [dbo].[message_status] ([id])
GO
ALTER TABLE [dbo].[need]  WITH CHECK ADD FOREIGN KEY([category_id])
REFERENCES [dbo].[category] ([id])
GO
ALTER TABLE [dbo].[need_Tag]  WITH CHECK ADD FOREIGN KEY([need_id])
REFERENCES [dbo].[need] ([id])
GO
ALTER TABLE [dbo].[need_Tag]  WITH CHECK ADD FOREIGN KEY([tag_id])
REFERENCES [dbo].[tag] ([id])
GO
ALTER TABLE [dbo].[offer]  WITH CHECK ADD FOREIGN KEY([product_id])
REFERENCES [dbo].[product] ([id])
GO
ALTER TABLE [dbo].[offer]  WITH CHECK ADD FOREIGN KEY([product_id])
REFERENCES [dbo].[product] ([id])
GO
ALTER TABLE [dbo].[offer]  WITH CHECK ADD FOREIGN KEY([product_id])
REFERENCES [dbo].[product] ([id])
GO
ALTER TABLE [dbo].[pledge]  WITH CHECK ADD FOREIGN KEY([offer_id])
REFERENCES [dbo].[offer] ([id])
GO
ALTER TABLE [dbo].[product]  WITH CHECK ADD FOREIGN KEY([id])
REFERENCES [dbo].[round] ([id])
GO
ALTER TABLE [dbo].[product_picture]  WITH CHECK ADD FOREIGN KEY([product_id])
REFERENCES [dbo].[product] ([id])
GO
ALTER TABLE [dbo].[round]  WITH CHECK ADD FOREIGN KEY([company_id])
REFERENCES [dbo].[company] ([id])
GO
ALTER TABLE [dbo].[round]  WITH CHECK ADD FOREIGN KEY([template_id])
REFERENCES [dbo].[template] ([id])
GO
ALTER TABLE [dbo].[round_need]  WITH CHECK ADD FOREIGN KEY([need_id])
REFERENCES [dbo].[need] ([id])
GO
ALTER TABLE [dbo].[round_need]  WITH CHECK ADD FOREIGN KEY([round_id])
REFERENCES [dbo].[round] ([id])
GO
ALTER TABLE [dbo].[round_need]  WITH CHECK ADD FOREIGN KEY([service_id])
REFERENCES [dbo].[service] ([id])
GO
ALTER TABLE [dbo].[round_need]  WITH CHECK ADD FOREIGN KEY([status_id])
REFERENCES [dbo].[status] ([id])
GO
ALTER TABLE [dbo].[round_need_endorsement]  WITH CHECK ADD FOREIGN KEY([endorser_id])
REFERENCES [dbo].[user] ([id])
GO
ALTER TABLE [dbo].[round_need_endorsement]  WITH CHECK ADD FOREIGN KEY([round_need_id])
REFERENCES [dbo].[round_need] ([id])
GO
ALTER TABLE [dbo].[round_need_tag]  WITH CHECK ADD FOREIGN KEY([round_need_id])
REFERENCES [dbo].[round_need] ([id])
GO
ALTER TABLE [dbo].[round_need_tag]  WITH CHECK ADD FOREIGN KEY([tag_id])
REFERENCES [dbo].[tag] ([id])
GO
ALTER TABLE [dbo].[service_need]  WITH CHECK ADD FOREIGN KEY([need_id])
REFERENCES [dbo].[need] ([id])
GO
ALTER TABLE [dbo].[service_need]  WITH CHECK ADD FOREIGN KEY([service_id])
REFERENCES [dbo].[service] ([id])
GO
ALTER TABLE [dbo].[service_round_need]  WITH CHECK ADD FOREIGN KEY([round_need_id])
REFERENCES [dbo].[round_need] ([id])
GO
ALTER TABLE [dbo].[service_round_need]  WITH CHECK ADD FOREIGN KEY([service_id])
REFERENCES [dbo].[service] ([id])
GO
ALTER TABLE [dbo].[stage]  WITH CHECK ADD  CONSTRAINT [FK__stage__workflow___64ECEE3F] FOREIGN KEY([workflow_id])
REFERENCES [dbo].[workflow] ([id])
GO
ALTER TABLE [dbo].[stage] CHECK CONSTRAINT [FK__stage__workflow___64ECEE3F]
GO
ALTER TABLE [dbo].[template_need]  WITH CHECK ADD FOREIGN KEY([need_id])
REFERENCES [dbo].[need] ([id])
GO
ALTER TABLE [dbo].[template_need]  WITH CHECK ADD FOREIGN KEY([template_id])
REFERENCES [dbo].[template] ([id])
GO
ALTER TABLE [dbo].[user]  WITH CHECK ADD FOREIGN KEY([currency_id])
REFERENCES [dbo].[currency] ([id])
GO
ALTER TABLE [dbo].[user_company]  WITH CHECK ADD FOREIGN KEY([company_id])
REFERENCES [dbo].[company] ([id])
GO
ALTER TABLE [dbo].[user_company]  WITH CHECK ADD FOREIGN KEY([role_id])
REFERENCES [dbo].[role] ([id])
GO
ALTER TABLE [dbo].[user_company]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[user] ([id])
GO
ALTER TABLE [dbo].[user_custom_skill]  WITH CHECK ADD FOREIGN KEY([skill_id])
REFERENCES [dbo].[skill] ([id])
GO
ALTER TABLE [dbo].[user_custom_skill]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[user] ([id])
GO
ALTER TABLE [dbo].[user_role]  WITH CHECK ADD FOREIGN KEY([role_id])
REFERENCES [dbo].[role] ([id])
GO
ALTER TABLE [dbo].[user_role]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[user] ([id])
GO
ALTER TABLE [dbo].[user_skill]  WITH CHECK ADD FOREIGN KEY([skill_id])
REFERENCES [dbo].[skill] ([id])
GO
ALTER TABLE [dbo].[user_skill]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[user] ([id])
GO
ALTER TABLE [dbo].[worker_service]  WITH CHECK ADD FOREIGN KEY([service_id])
REFERENCES [dbo].[service] ([id])
GO
ALTER TABLE [dbo].[worker_service]  WITH CHECK ADD FOREIGN KEY([worker_id])
REFERENCES [dbo].[worker] ([id])
GO
USE [master]
GO
ALTER DATABASE [UFO_Dev] SET  READ_WRITE 
GO
