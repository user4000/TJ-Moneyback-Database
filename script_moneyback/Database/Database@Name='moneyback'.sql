USE [master]
GO

CREATE DATABASE [moneyback]
 CONTAINMENT = NONE

 COLLATE Cyrillic_General_CI_AI
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [moneyback].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [moneyback] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [moneyback] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [moneyback] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [moneyback] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [moneyback] SET ARITHABORT OFF 
GO

ALTER DATABASE [moneyback] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [moneyback] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [moneyback] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [moneyback] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [moneyback] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [moneyback] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [moneyback] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [moneyback] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [moneyback] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [moneyback] SET  DISABLE_BROKER 
GO

ALTER DATABASE [moneyback] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [moneyback] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [moneyback] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [moneyback] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [moneyback] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [moneyback] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [moneyback] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [moneyback] SET RECOVERY FULL 
GO

ALTER DATABASE [moneyback] SET  MULTI_USER 
GO

ALTER DATABASE [moneyback] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [moneyback] SET DB_CHAINING OFF 
GO

ALTER DATABASE [moneyback] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [moneyback] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO

USE [moneyback]
GO

CREATE USER [admin] FOR LOGIN [admin] WITH DEFAULT_SCHEMA=[dbo]
GO

GRANT CONNECT TO [admin] AS [dbo]
GO

ALTER DATABASE [moneyback] SET  READ_WRITE 
GO

