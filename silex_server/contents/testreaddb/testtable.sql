-- phpMyAdmin SQL Dump
-- version 3.2.5
-- http://www.phpmyadmin.net
--
-- Serveur: localhost
-- Généré le : Mar 07 Décembre 2010 à 15:22
-- Version du serveur: 5.1.44
-- Version de PHP: 5.2.13

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Base de données: `test`
--

-- --------------------------------------------------------

--
-- Structure de la table `testtable`
--

CREATE TABLE `testtable` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `age` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Contenu de la table `testtable`
--

INSERT INTO `testtable` VALUES(1, 'ariel', 32);
INSERT INTO `testtable` VALUES(2, 'gerard', 55);
