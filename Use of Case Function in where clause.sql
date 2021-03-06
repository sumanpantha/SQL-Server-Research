begin 
declare 
@RoleId   uniqueidentifier =  '0626CA90-4905-4FB5-8296-504EFAE0E544',
@UserId      uniqueidentifier = 'B6E8D7BD-7183-405D-B723-F1E76DBAB741';


SELECT * FROM DocumentProcessingRemarks
SELECT * FROM DocumentProcessingSetting

  select 
        ps.Id as KeyId,
        dps.Id as SettingId,
		dps.DocumentType,
		dps.DocumentProcessingType,
        case when ps.Step = 1 then ps.CreatedDate else 
        (
        select CreatedDate from DocumentProcessingRemarks dpr
        inner join DocumentProcessingSetting dprs on dprs.Id = dpr.DocumentProcessingSettingId
        and dprs.Step = ps.Step - 1 and dprs.DocumentType =14 and ps.Id = dpr.EntityId
        ) end as [Date],
       'Irregular Transaction "'+ Format(ps.CreatedDate,'dd/MM/yyyy') +'" for "'+ b.Name +'" is waiting for your response' as [Description],
       'notification/irregulartransaction/'+Convert(nvarchar(max),ps.Id)+'/'+Convert(nvarchar(max),dps.Id) as Link
  from IrregularTransaction ps
    inner Join [DocumentProcessingSetting] dps 
	on dps.Step = ps.Step  and dps.DocumentType = 14  and dps.RoleId = @RoleId and ps.Status=0
    inner join [UserRole] ur on ur.RoleId = dps.RoleId and ur.UserId = @UserId
    inner join [Role] r on r.Id = dps.RoleId
    inner join Branch b on b.Id = (case when ps.EntityType = 2 then   ps.SubEntityId  end)
    inner join Agent a on a.Id = (case when ps.EntityType =1 then  ps.SubEntityId end) 
    inner join Businessunit bu on bu.Id =( case when ps.EntityType =3 then  ps.SubEntityId end)
    inner join [UserBranch] ub on ub.UserId = ur.UserId and (r.RoleType = 2 or ub.BranchId = ps.SubEntityId) 

end;

