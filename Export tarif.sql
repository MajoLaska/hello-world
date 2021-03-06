/****** Script for SelectTopNRows command from SSMS  ******/

use IntranetAspNet;

declare @den date = '2014-07-01';

WITH nakladove_CTE (RokMesiac, Rozdeleni, OsobniCislo, DatumNastupu, Funkcia)
as
(
    SELECT        RokMesiac, Rozdeleni, OsobniCislo, DatumNastupu, Funkcia
    FROM            RON_DM.dbo.RokMesiacNS
    WHERE        (RokMesiac = CONVERT(varchar(6), @den, 112)) and Rozdeleni BETWEEN 99 AND 999 and funkcia in (13,12,11)
)
, uvazky_CTE (OsobniCislo, DatumNastupu, Hodiny, Dny, KalendarniDny)
as
(SELECT        OsobniCislo, DatumNastupu, Hodiny, Dny, KalendarniDny
    FROM            RON_DM.dbo.MesicniVysledekVypoctu
    WHERE        (TypCasoveSlozkyMzdy = '600fond') AND (Mesic = dbo.BOMonth(@den))
)
SELECT        RokMesiac, fnr, meno, priezvisko, id_user, pozicia_nazov, pozicia, uvazok_den, uvazok_den * 5 AS uvazok_tyzden,
CONVERT(varchar(10), GETDATE(),121) as datum
 , region
FROM            (SELECT        ns.RokMesiac, ns.Rozdeleni AS fnr, osoba.Jmeno AS meno, osoba.Prijmeni AS priezvisko, ns.OsobniCislo AS id_user, NULL AS pozicia_nazov, 
                                                    CASE WHEN [Funkcia] = 12 THEN 1 ELSE 0 END AS pozicia, CASE WHEN uvazky.Dny > 0 THEN (uvazky.Hodiny / uvazky.Dny) 
                                                    ELSE 0 END AS uvazok_den, regiony.Region AS region
                          FROM            nakladove_CTE AS ns LEFT OUTER JOIN
                                                    RON_DM.dbo.Osoba AS osoba ON ns.OsobniCislo = osoba.RC LEFT OUTER JOIN
                                                    ron.PlatoveRegiony AS regiony ON ns.Rozdeleni = regiony.CisloFilialky LEFT OUTER JOIN
                                                        uvazky_CTE AS uvazky ON ns.OsobniCislo = uvazky.OsobniCislo AND 
                                                    ns.DatumNastupu = uvazky.DatumNastupu
                          WHERE        (uvazky.Hodiny IS NOT NULL) ) AS exportTarify
ORDER BY fnr, pozicia DESC, id_user





-- Úväzky, ale len neuzavreté obdobia

SELECT        OsobniCislo, DatumNastupu, Hodiny, Dny, KalendarniDny, 
   (CASE WHEN Dny > 0 THEN (Hodiny / Dny) ELSE 0 END) * 5 AS uvazok_tyzden
    FROM            RON_DM.dbo.MesicniVysledekVypoctu
    WHERE        (TypCasoveSlozkyMzdy = '600fond') AND (Mesic = '2014-06-01') and OsobniCislo = 6286

SELECT        OsobniCislo, DatumNastupu,Mesic, Hodiny, Dny,
   CASE WHEN Dny > 0 THEN (Hodiny / Dny) ELSE 0 END AS uvazok_den
    FROM            MesicniVysledekVypoctu
    WHERE        (TypCasoveSlozkyMzdy = '600fond') 
    AND (Mesic >= (
                 SELECT          MIN(PocatekObdobi) AS PocatekZpracovani 
                 FROM            Obdobi 
                 WHERE           (Aplikace = 'ADS') 
                            AND  (Uzavreno = 0) 
                            AND  (PocatekObdobi > ALL (
                                  SELECT          PocatekObdobi 
                                  FROM            Obdobi 
                                  WHERE           (Aplikace = 'ADS') 
                                             AND  (Uzavreno <> 0)
                                 )) ))


/*provizie ***/
Select distinct TypCasoveSlozkyMzdy from RON_DM.dbo.MesicniVysledekVypoctu
where upper(TypCasoveSlozkyMzdy) like (Upper('800%')) 


Select distinct * from RON_DM.dbo.MesicniVysledekVypoctu
where (
upper(TypCasoveSlozkyMzdy) like Upper('800provImp'))  and Mesic = '2014-07-01'
order by RC