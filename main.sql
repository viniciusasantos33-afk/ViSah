-- Criação do Banco de Dados
CREATE DATABASE ViSahDB;
GO

USE ViSahDB;
GO

-- TABELAS INDEPENDENTES E DE DOMÍNIO

-- Tabela de Perfis de Usuário
CREATE TABLE TipoUsuario (
    IdTipoUsuario INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL UNIQUE
);

-- Tabela de Gêneros Musicais
CREATE TABLE Genero (
    IdGenero INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL UNIQUE
);

-- Tabela de Sentimentos
CREATE TABLE Sentimento (
    IdSentimento INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL UNIQUE
);

-- Tabela de Artistas
CREATE TABLE Artista (
    IdArtista INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    FotoUrl VARCHAR(500) NULL,
    Biografia VARCHAR(MAX) NULL,
    DataCriacao DATETIME NOT NULL DEFAULT GETDATE(),
    Ouvintes INT NOT NULL DEFAULT 0
);

-- TABELAS DEPENDENTES PRINCIPAIS

-- Tabela de Usuários
CREATE TABLE Usuario (
    IdUsuario INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Email VARCHAR(50) NOT NULL UNIQUE,
    SenhaHash VARCHAR(255) NOT NULL,
    IdTipoUsuario INT NOT NULL,
    Ativo BIT NOT NULL DEFAULT 1,
    DataCriacao DATETIME NOT NULL DEFAULT GETDATE(),
    FotoUrl VARCHAR(500) NULL,
    CONSTRAINT FK_Usuario_TipoUsuario FOREIGN KEY (IdTipoUsuario) REFERENCES TipoUsuario(IdTipoUsuario)
);

-- Tabela de Álbuns
CREATE TABLE Album (
    IdAlbum INT IDENTITY(1,1) PRIMARY KEY,
    Titulo VARCHAR(150) NOT NULL,
    CapaUrl VARCHAR(500) NULL,
    DataLancamento DATE NULL,
    Ouvintes INT NOT NULL DEFAULT 0,
    IdArtista INT NOT NULL,
    CONSTRAINT FK_Album_Artista FOREIGN KEY (IdArtista) REFERENCES Artista(IdArtista) ON DELETE CASCADE
);

-- Tabela de Músicas (Tabela Central)
CREATE TABLE Musica (
    IdMusica INT IDENTITY(1,1) PRIMARY KEY,
    Titulo VARCHAR(150) NOT NULL,
    ArquivoAudioUrl VARCHAR(500) NOT NULL,
    CapaUrl VARCHAR(500) NULL,
    DataLancamento DATE NOT NULL DEFAULT GETDATE(),
    Ouvintes BIGINT NOT NULL DEFAULT 0,
    DuracaoSegundos INT NOT NULL,
    IdArtista INT NOT NULL,
    IdAlbum INT NULL, -- Opcional 
    IdGenero INT NOT NULL,
    IdSentimento INT NOT NULL,
    CONSTRAINT FK_Musica_Artista FOREIGN KEY (IdArtista) REFERENCES Artista(IdArtista),
    CONSTRAINT FK_Musica_Album FOREIGN KEY (IdAlbum) REFERENCES Album(IdAlbum) ON DELETE SET NULL,
    CONSTRAINT FK_Musica_Genero FOREIGN KEY (IdGenero) REFERENCES Genero(IdGenero),
    CONSTRAINT FK_Musica_Sentimento FOREIGN KEY (IdSentimento) REFERENCES Sentimento(IdSentimento)
);

-- Tabela de Playlists
CREATE TABLE Playlist (
    IdPlaylist INT IDENTITY(1,1) PRIMARY KEY,
    Titulo VARCHAR(100) NOT NULL,
    Descricao VARCHAR(255) NULL,
    EhPublica BIT NOT NULL DEFAULT 0,
    DataCriacao DATETIME NOT NULL DEFAULT GETDATE(),
    IdUsuario INT NOT NULL,
    CONSTRAINT FK_Playlist_Usuario FOREIGN KEY (IdUsuario) REFERENCES Usuario(IdUsuario) ON DELETE CASCADE
);

-- TABELAS INTERMEDIÁRIAS (RELACIONAMENTOS N:M)

-- Músicas Favoritadas pelos Usuários
CREATE TABLE FavoritosMusicas (
    IdUsuario INT NOT NULL,
    IdMusica INT NOT NULL,
    DataAdicao DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (IdUsuario, IdMusica),
    CONSTRAINT FK_FavMusica_Usuario FOREIGN KEY (IdUsuario) REFERENCES Usuario(IdUsuario) ON DELETE CASCADE,
    CONSTRAINT FK_FavMusica_Musica FOREIGN KEY (IdMusica) REFERENCES Musica(IdMusica) ON DELETE CASCADE
);

-- Artistas Seguidos pelos Usuários
CREATE TABLE FavoritosArtistas (
    IdUsuario INT NOT NULL,
    IdArtista INT NOT NULL,
    DataAdicao DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (IdUsuario, IdArtista),
    CONSTRAINT FK_FavArtista_Usuario FOREIGN KEY (IdUsuario) REFERENCES Usuario(IdUsuario) ON DELETE CASCADE,
    CONSTRAINT FK_FavArtista_Artista FOREIGN KEY (IdArtista) REFERENCES Artista(IdArtista) ON DELETE CASCADE
);

-- Associação entre Playlists e Músicas
CREATE TABLE PlaylistMusicas (
    IdPlaylist INT NOT NULL,
    IdMusica INT NOT NULL,
    Ordem INT NOT NULL,
    DataAdicao DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (IdPlaylist, IdMusica),
    CONSTRAINT FK_PM_Playlist FOREIGN KEY (IdPlaylist) REFERENCES Playlist(IdPlaylist) ON DELETE CASCADE,
    CONSTRAINT FK_PM_Musica FOREIGN KEY (IdMusica) REFERENCES Musica(IdMusica) ON DELETE CASCADE
);
GO

-- Inserções

-- Inserir Perfis
INSERT INTO TipoUsuario (Nome) VALUES ('Administrador'), ('Comum');

-- Inserir Gêneros 
INSERT INTO Genero (Nome) VALUES ('Jazz'), ('Soul'), ('Hip-hop'), ('R&B'), ('Eletronica'), ('Rock'), ('MPB');

-- Inserir Sentimentos
INSERT INTO Sentimento (Nome) VALUES ('Alegre'), ('Calmo'), ('Triste'), ('Energia'), ('Intensidade'), ('Felicidade');
GO

-- ÍNDICES PARA MELHORAR A PERFORMANCE

-- Otimiza a filtragem cruzada simultânea
CREATE NONCLUSTERED INDEX IX_Musica_Genero_Sentimento 
ON Musica (IdGenero, IdSentimento) 
INCLUDE (IdMusica, Titulo, CapaUrl, Ouvintes, ArquivoAudioUrl);

CREATE NONCLUSTERED INDEX IX_Musica_Ouvintes 
ON Musica (Ouvintes DESC);
GO