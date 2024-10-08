--  pAYChistorialCuentasPorSocio.sql
IF (OBJECT_ID('pAYChistorialCuentasPorSocio') IS NOT NULL)
        BEGIN
            DROP PROC pAYChistorialCuentasPorSocio
            SELECT 'pAYChistorialCuentasPorSocio BORRADO' AS info
        END
GO

CREATE PROC DBO.pAYChistorialCuentasPorSocio
    @pNoSocio AS VARCHAR(20)=''
AS
BEGIN
DECLARE @IdSocio AS INT=(SELECT
                             sc.idsocio
                         FROM tSCSsocios sc WITH (NOLOCK)
                         WHERE sc.Codigo=@pNoSocio)

IF @IdSocio IS NULL OR @IdSocio=0
BEGIN
    SELECT
        'Socio no encontrado'
    RETURN -1
END

SELECT
    suc.Descripcion AS Sucursal,
    gpos.Grupo,
    sc.Codigo AS NoSocio
  , sc.EsSocioValido
  , sc.FechaAlta
  , p.Nombre
    ,td.Descripcion AS TipoCuenta
  , c.Codigo AS NoCuenta
  , pf.Descripcion AS Producto
  , c.FechaAlta
  , c.Vencimiento
  , c.Monto
    , est.Descripcion AS Estatus
FROM dbo.tSCSsocios sc WITH (NOLOCK)
INNER JOIN dbo.tGRLpersonas p WITH (NOLOCK)
        ON p.IdPersona = sc.IdPersona
INNER JOIN tCTLsucursales suc WITH (NOLOCK)
    ON sc.IdSucursal = suc.IdSucursal
LEFT JOIN (
    SELECT
        asig.IdSocio,
        gpo.Descripcion AS Grupo
    FROM tAYCgrupos gpo WITH (NOLOCK)
    INNER JOIN tCTLestatusActual ea WITH (NOLOCK)
        ON gpo.IdEstatusActual = ea.IdEstatusActual
            AND IdEstatus=1
    INNER JOIN tAYCintegrantesAsignados asig WITH (NOLOCK)
        ON asig.IdRel = gpo.IdRelIntegrantes
            AND asig.IdEstatus=1
                AND asig.IdSocio>0
) gpos ON gpos.IdSocio=sc.IdSocio
INNER JOIN dbo.tAYCcuentas c WITH (NOLOCK)
        ON c.IdSocio = sc.IdSocio
INNER JOIN tCTLestatus est WITH (NOLOCK)
    ON c.IdEstatus = est.IdEstatus
INNER JOIN tAYCproductosFinancieros pf WITH (NOLOCK)
    ON c.IdProductoFinanciero = pf.IdProductoFinanciero
INNER JOIN tctltiposd td WITH (NOLOCK)
    ON pf.IdTipoDDominioCatalogo = td.IdTipoD
WHERE sc.IdSocio=@IdSocio

    RETURN 0
END
GO
SELECT 'pAYChistorialCuentasPorSocio CREADO' AS info
GO


