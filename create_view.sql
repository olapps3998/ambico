create view v_att_log as
Select att_log.sn As sn,
  att_log.scan_date As scan_date,
  att_log.pin As pin,
  att_log.att_id As att_id,
  Cast(Date_Format(att_log.scan_date, '%Y-%m-%d') As date) As scan_date_tgl,
  Date_Format(att_log.scan_date, '%d-%m-%Y %H:%i:%s') As scan_date_tgl_jam,
  pegawai.pegawai_nip As pegawai_nip,
  pegawai.pegawai_nama As pegawai_nama
From att_log
  Left Join pegawai On att_log.pin = pegawai.pegawai_pin;

create view v_jdw_krj_def as
Select t_jdw_krj_def.pegawai_id As pegawai_id,
  t_jdw_krj_def.tgl As tgl,
  t_jdw_krj_def.jk_id As jk_id,
  t_jdw_krj_def.scan_masuk As scan_masuk,
  t_jdw_krj_def.scan_keluar As scan_keluar,
  t_jdw_krj_def.hk_def As hk_def,
  pegawai.pegawai_nip As pegawai_nip,
  pegawai.pegawai_nama As pegawai_nama,
  t_jk.jk_kd As jk_kd,
  pembagian2.pembagian2_nama As pembagian2_nama,
  pegawai.pembagian2_id As pembagian2_id,
  pegawai.pegawai_pin As pegawai_pin,
  t_lapgroup.lapgroup_nama As lapgroup_nama
From ((((t_jdw_krj_def
  Join pegawai On t_jdw_krj_def.pegawai_id = pegawai.pegawai_id)
  Join t_jk On t_jdw_krj_def.jk_id = t_jk.jk_id)
  Join pembagian2 On pegawai.pembagian2_id = pembagian2.pembagian2_id)
  Left Join t_lapsubgroup
    On pegawai.pembagian2_id = t_lapsubgroup.pembagian2_id)
  Join t_lapgroup On t_lapsubgroup.lapgroup_id = t_lapgroup.lapgroup_id;



create view v_jdw_krj_brngan as
Select a.pegawai_id As pegawai_id,
  b.tgl As tgl,
  a.scan_masuk As scan_masuk,
  a.scan_keluar As scan_keluar,
  c.pegawai_nip As pegawai_nip,
  c.pegawai_nama As pegawai_nama,
  c.pegawai_pin As pegawai_pin
From (t_keg_detail a
  Left Join t_keg_master b On a.kegm_id = b.kegm_id)
  Left Join pegawai c On a.pegawai_id = c.pegawai_id;

create view v_rekon_brngan as
Select b.pegawai_nama As pegawai_nama,
  Cast(a.scan_date As date) As tgl,
  Min(a.scan_date) As scan_masuk,
  Max(a.scan_date) As scan_keluar,
  b.pegawai_id As pegawai_id
From att_log a
  Left Join pegawai b On a.pin = b.pegawai_pin
Where b.pegawai_id In (Select t_keg_detail.pegawai_id As pegawai_id
  From t_keg_detail)
Group By Concat(Cast(a.scan_date As date), b.pegawai_id);

CREATE VIEW `v_keg_pembagi` AS select `t_keg_detail`.`kegm_id` AS `kegm_id`,sum((case when ((`t_keg_detail`.`scan_masuk` is not null) and (`t_keg_detail`.`scan_keluar` is not null)) then 1 else 0 end)) AS `pembagi` from `t_keg_detail` group by `t_keg_detail`.`kegm_id`;
CREATE VIEW `v_keg_hasil` AS select `t_keg_master`.`kegm_id` AS `kegm_id`,`t_keg_master`.`keg_id` AS `keg_id`,`t_keg_master`.`tgl` AS `tgl`,`t_keg_master`.`shift` AS `shift`,`t_keg_master`.`hasil` AS `hasil`,`t_keg_detail`.`kegd_id` AS `kegd_id`,`t_kegiatan`.`keg_nama` AS `keg_nama`,`t_kegiatan`.`tarif_acuan` AS `tarif_acuan`,`t_kegiatan`.`tarif1` AS `tarif1`,`t_kegiatan`.`tarif2` AS `tarif2`,`t_kegiatan`.`keg_ket` AS `keg_ket`,`v_keg_pembagi`.`pembagi` AS `pembagi`,`pegawai`.`pegawai_nama` AS `pegawai_nama`,`f_pembulatan`(round(((case when (`t_kegiatan`.`tarif_acuan` = 0) then (`t_keg_master`.`hasil` * `t_kegiatan`.`tarif1`) else ((case when (`t_keg_master`.`hasil` <= `t_kegiatan`.`tarif_acuan`) then `t_kegiatan`.`tarif1` else `t_kegiatan`.`tarif2` end) * `t_keg_master`.`hasil`) end) / `v_keg_pembagi`.`pembagi`),0)) AS `upah_peg`,concat(cast(`t_keg_master`.`tgl` as char charset utf8),' ',cast(format(`t_keg_master`.`hasil`,0) as char charset utf8)) AS `header_` from ((((`t_keg_master` join `t_keg_detail` on((`t_keg_master`.`kegm_id` = `t_keg_detail`.`kegm_id`))) join `t_kegiatan` on((`t_keg_master`.`keg_id` = `t_kegiatan`.`keg_id`))) join `v_keg_pembagi` on((`t_keg_master`.`kegm_id` = `v_keg_pembagi`.`kegm_id`))) join `pegawai` on((`t_keg_detail`.`pegawai_id` = `pegawai`.`pegawai_id`)));

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_lapgjhrn` AS select `e`.`lapgroup_id` AS `lapgroup_id`,`e`.`lapgroup_nama` AS `lapgroup_nama`,`e`.`lapgroup_index` AS `lapgroup_index`,`d`.`lapsubgroup_index` AS `lapsubgroup_index`,`a`.`pegawai_id` AS `pegawai_id`,`a`.`tgl` AS `tgl`,`a`.`jk_id` AS `jk_id`,`a`.`scan_masuk` AS `scan_masuk`,`a`.`scan_keluar` AS `scan_keluar`,`a`.`hk_def` AS `hk_def`,`a`.`pegawai_nip` AS `pegawai_nip`,`a`.`pegawai_nama` AS `pegawai_nama`,`a`.`jk_kd` AS `jk_kd`,`a`.`pembagian2_nama` AS `pembagian2_nama`,`a`.`pembagian2_id` AS `pembagian2_id`,`c`.`rumus_id` AS `rumus_id`,`c`.`rumus_nama` AS `rumus_nama`,`c`.`hk_gol` AS `hk_gol`,`c`.`umr` AS `umr`,`c`.`hk_jml` AS `hk_jml`,`c`.`upah` AS `upah`,`c`.`premi_hadir` AS `premi_hadir`,`c`.`premi_malam` AS `premi_malam`,`c`.`pot_absen` AS `pot_absen`,`c`.`lembur` AS `lembur`,(case when (isnull(`a`.`scan_masuk`) and isnull(`a`.`scan_keluar`)) then 0 else `c`.`upah` end) AS `upah2`,(case when (right(`a`.`jk_kd`,2) = 'S3') then `c`.`premi_malam` else 0 end) AS `premi_malam2`,(case when (count((isnull(`a`.`scan_masuk`) and isnull(`a`.`scan_keluar`) and (right(`a`.`jk_kd`,1) <> 'L'))) > 1) then 0 else `c`.`premi_hadir` end) AS `premi_hadir2` from ((((`v_jdw_krj_def` `a` left join `t_rumus_peg` `b` on((`a`.`pegawai_id` = `b`.`pegawai_id`))) left join `t_rumus` `c` on((`b`.`rumus_id` = `c`.`rumus_id`))) left join `t_lapsubgroup` `d` on((`a`.`pembagian2_id` = `d`.`pembagian2_id`))) left join `t_lapgroup` `e` on((`d`.`lapgroup_id` = `e`.`lapgroup_id`))) where ((`c`.`hk_gol` = `a`.`hk_def`) and (not(`a`.`pegawai_id` in (select `t_rumus2_peg`.`pegawai_id` AS `pegawai_id` from `t_rumus2_peg`)))) order by `e`.`lapgroup_index`,`d`.`lapsubgroup_index`,`a`.`pegawai_id`,`a`.`tgl`;
