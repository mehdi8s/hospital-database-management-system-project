--
-- PostgreSQL database dump
--

-- Dumped from database version 16.0
-- Dumped by pg_dump version 16.0

-- Started on 2023-12-26 05:48:36

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 237 (class 1255 OID 16914)
-- Name: kontrol_harcama_toplami(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kontrol_harcama_toplami() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    harcama_toplami NUMERIC;
BEGIN
SELECT SUM(harcama_miktari) INTO harcama_toplami
    FROM hastane_harcamalari;
	 IF harcama_toplami >= 1000000 THEN
        RAISE EXCEPTION 'Hastane harcamalarının toplamı 1 milyon veya daha fazla. Dikkat!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.kontrol_harcama_toplami() OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 16917)
-- Name: kontrol_maas_tutari(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kontrol_maas_tutari() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.maas_tutari >= 100000 THEN
        RAISE EXCEPTION 'Maaş tutarı 100 bin veya daha fazla. Dikkat!';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.kontrol_maas_tutari() OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 16907)
-- Name: personel_kontrolu(text, text, refcursor); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.personel_kontrolu(text, text, refcursor) RETURNS refcursor
    LANGUAGE plpgsql
    AS $_$
DECLARE
kontrolad TEXT := $1;
kontrolsoyad TEXT := $2;
results REFCURSOR := $3;
BEGIN
open results FOR
select *
from personel
where personel.ad like kontrolad
and
personel.soyad like kontrolsoyad;
return results;
end;
$_$;


ALTER FUNCTION public.personel_kontrolu(text, text, refcursor) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 16912)
-- Name: personel_sayisi_kontrolu(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.personel_sayisi_kontrolu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (SELECT COUNT(*) FROM personel) >= 50 THEN
        RAISE EXCEPTION 'Personel limit (50) reached. Cannot add more personnel.';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.personel_sayisi_kontrolu() OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 16906)
-- Name: personel_yakini_sayisi(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.personel_yakini_sayisi(OUT tcount integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
select count(*)
into tcount
from personel_yakini;
end;$$;


ALTER FUNCTION public.personel_yakini_sayisi(OUT tcount integer) OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 16903)
-- Name: personelsayisi(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.personelsayisi(OUT scount integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
select count(*)
into scount
from personel;
end;$$;


ALTER FUNCTION public.personelsayisi(OUT scount integer) OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 16905)
-- Name: toplam_harcama(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.toplam_harcama(OUT toplam integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
select sum(toplam_harcama) into toplam from hastane_harcamalari;
end;
$$;


ALTER FUNCTION public.toplam_harcama(OUT toplam integer) OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 16908)
-- Name: yas_kontrolu(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.yas_kontrolu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
if(NEW.dogum_tarihi> 1950-01-01) then
delete from personel where dogum_tarihi = NEW.dogum_tarihi;
end if;
return NEW;
end;
$$;


ALTER FUNCTION public.yas_kontrolu() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16761)
-- Name: cinsiyet; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cinsiyet (
    cinsiyet_id integer NOT NULL,
    cinsiyet character varying(10) NOT NULL
);


ALTER TABLE public.cinsiyet OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16836)
-- Name: doktor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doktor (
    personel_id integer NOT NULL,
    uzmanlik_id integer NOT NULL
);


ALTER TABLE public.doktor OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16777)
-- Name: hastane_harcamalari; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hastane_harcamalari (
    harcama_id integer NOT NULL,
    personel_id integer NOT NULL,
    toplam_harcama bigint NOT NULL
);


ALTER TABLE public.hastane_harcamalari OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16877)
-- Name: hemsire; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hemsire (
    personel_id integer NOT NULL,
    uzmanlik_id integer NOT NULL
);


ALTER TABLE public.hemsire OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16734)
-- Name: il_bilgileri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.il_bilgileri (
    il_id integer NOT NULL,
    il_adi character varying(20) NOT NULL,
    ilce_id integer NOT NULL
);


ALTER TABLE public.il_bilgileri OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16739)
-- Name: ilce_bilgileri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ilce_bilgileri (
    ilce_id integer NOT NULL,
    ilce_adi character varying(20) NOT NULL
);


ALTER TABLE public.ilce_bilgileri OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16724)
-- Name: iletisim_bilgileri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.iletisim_bilgileri (
    iletisim_id integer NOT NULL,
    telefon character varying(12) NOT NULL,
    ulke_id integer NOT NULL
);


ALTER TABLE public.iletisim_bilgileri OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16825)
-- Name: maas_bilgileri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.maas_bilgileri (
    maas_id integer NOT NULL,
    maas_tutari integer NOT NULL,
    odeme_durumu_id integer NOT NULL
);


ALTER TABLE public.maas_bilgileri OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16820)
-- Name: maas_odeme_durumu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.maas_odeme_durumu (
    odeme_durumu_id integer NOT NULL,
    odeme_durumu boolean NOT NULL
);


ALTER TABLE public.maas_odeme_durumu OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16719)
-- Name: personel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personel (
    personel_id integer NOT NULL,
    ad character varying(30) NOT NULL,
    soyad character varying(30) NOT NULL,
    dogum_tarihi date NOT NULL,
    iletisim_bilgileri_id integer NOT NULL,
    cinsiyet_id integer NOT NULL,
    maas_id integer NOT NULL
);


ALTER TABLE public.personel OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16792)
-- Name: personel_vardiyalari; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personel_vardiyalari (
    vardiya_id integer NOT NULL,
    personel_id integer NOT NULL,
    tarih date NOT NULL
);


ALTER TABLE public.personel_vardiyalari OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16766)
-- Name: personel_yakini; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personel_yakini (
    personel_yakini_id integer NOT NULL,
    ad character varying(30) NOT NULL,
    soyad character varying(30) NOT NULL,
    personel_id integer NOT NULL
);


ALTER TABLE public.personel_yakini OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16862)
-- Name: teknisyen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teknisyen (
    personel_id integer NOT NULL,
    uzmanlik_id integer NOT NULL
);


ALTER TABLE public.teknisyen OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16729)
-- Name: ulke_bilgileri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ulke_bilgileri (
    ulke_id integer NOT NULL,
    ulke_adi character varying(25) NOT NULL,
    il_id integer NOT NULL
);


ALTER TABLE public.ulke_bilgileri OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16851)
-- Name: uzmanlik_alani; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.uzmanlik_alani (
    uzmanlik_id integer NOT NULL,
    uzmanlik_adi character varying(30) NOT NULL
);


ALTER TABLE public.uzmanlik_alani OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16787)
-- Name: vardiyalar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vardiyalar (
    vardiya_id integer NOT NULL,
    baslama_saati integer NOT NULL,
    bitis_saati integer NOT NULL
);


ALTER TABLE public.vardiyalar OWNER TO postgres;

--
-- TOC entry 4909 (class 0 OID 16761)
-- Dependencies: 220
-- Data for Name: cinsiyet; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cinsiyet (cinsiyet_id, cinsiyet) FROM stdin;
2	Bayan
1	Bay
\.


--
-- TOC entry 4916 (class 0 OID 16836)
-- Dependencies: 227
-- Data for Name: doktor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doktor (personel_id, uzmanlik_id) FROM stdin;
1	1
\.


--
-- TOC entry 4911 (class 0 OID 16777)
-- Dependencies: 222
-- Data for Name: hastane_harcamalari; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hastane_harcamalari (harcama_id, personel_id, toplam_harcama) FROM stdin;
1	1	18000
2	2	50000
\.


--
-- TOC entry 4919 (class 0 OID 16877)
-- Dependencies: 230
-- Data for Name: hemsire; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hemsire (personel_id, uzmanlik_id) FROM stdin;
3	3
\.


--
-- TOC entry 4907 (class 0 OID 16734)
-- Dependencies: 218
-- Data for Name: il_bilgileri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.il_bilgileri (il_id, il_adi, ilce_id) FROM stdin;
2	Tahran	2
1	Sakarya	1
\.


--
-- TOC entry 4908 (class 0 OID 16739)
-- Dependencies: 219
-- Data for Name: ilce_bilgileri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ilce_bilgileri (ilce_id, ilce_adi) FROM stdin;
2	Fardis
1	Serdivan
\.


--
-- TOC entry 4905 (class 0 OID 16724)
-- Dependencies: 216
-- Data for Name: iletisim_bilgileri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.iletisim_bilgileri (iletisim_id, telefon, ulke_id) FROM stdin;
2	05524798790	2
1	05302226129	1
\.


--
-- TOC entry 4915 (class 0 OID 16825)
-- Dependencies: 226
-- Data for Name: maas_bilgileri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maas_bilgileri (maas_id, maas_tutari, odeme_durumu_id) FROM stdin;
1	18000	1
2	50000	1
\.


--
-- TOC entry 4914 (class 0 OID 16820)
-- Dependencies: 225
-- Data for Name: maas_odeme_durumu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maas_odeme_durumu (odeme_durumu_id, odeme_durumu) FROM stdin;
1	t
2	f
\.


--
-- TOC entry 4904 (class 0 OID 16719)
-- Dependencies: 215
-- Data for Name: personel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personel (personel_id, ad, soyad, dogum_tarihi, iletisim_bilgileri_id, cinsiyet_id, maas_id) FROM stdin;
1	Melih	Yasak	2000-01-20	1	1	1
2	Mehdi	Shahrouei	2003-07-16	2	1	2
3	Elif\n	Kaya	2000-01-01	1	2	2
\.


--
-- TOC entry 4913 (class 0 OID 16792)
-- Dependencies: 224
-- Data for Name: personel_vardiyalari; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personel_vardiyalari (vardiya_id, personel_id, tarih) FROM stdin;
1	1	2023-12-06
2	1	2023-12-19
\.


--
-- TOC entry 4910 (class 0 OID 16766)
-- Dependencies: 221
-- Data for Name: personel_yakini; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personel_yakini (personel_yakini_id, ad, soyad, personel_id) FROM stdin;
1	Ali	Yilmaz	2
2	Emre	Can\n	1
\.


--
-- TOC entry 4918 (class 0 OID 16862)
-- Dependencies: 229
-- Data for Name: teknisyen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teknisyen (personel_id, uzmanlik_id) FROM stdin;
\.


--
-- TOC entry 4906 (class 0 OID 16729)
-- Dependencies: 217
-- Data for Name: ulke_bilgileri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ulke_bilgileri (ulke_id, ulke_adi, il_id) FROM stdin;
2	Iran	2
1	Turkiye	1
\.


--
-- TOC entry 4917 (class 0 OID 16851)
-- Dependencies: 228
-- Data for Name: uzmanlik_alani; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.uzmanlik_alani (uzmanlik_id, uzmanlik_adi) FROM stdin;
4	Elektrik 
3	Hasta Bakimi
2	Fiziyotrapi
1	Dahiliye
\.


--
-- TOC entry 4912 (class 0 OID 16787)
-- Dependencies: 223
-- Data for Name: vardiyalar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vardiyalar (vardiya_id, baslama_saati, bitis_saati) FROM stdin;
3	17	23
2	12	17
1	7	12
\.


--
-- TOC entry 4716 (class 2606 OID 16765)
-- Name: cinsiyet cinsiyet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cinsiyet
    ADD CONSTRAINT cinsiyet_pkey PRIMARY KEY (cinsiyet_id);


--
-- TOC entry 4733 (class 2606 OID 16840)
-- Name: doktor doktor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doktor
    ADD CONSTRAINT doktor_pkey PRIMARY KEY (personel_id);


--
-- TOC entry 4721 (class 2606 OID 16781)
-- Name: hastane_harcamalari hastane_harcamalari_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hastane_harcamalari
    ADD CONSTRAINT hastane_harcamalari_pkey PRIMARY KEY (harcama_id);


--
-- TOC entry 4740 (class 2606 OID 16881)
-- Name: hemsire hemsire_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hemsire
    ADD CONSTRAINT hemsire_pkey PRIMARY KEY (personel_id);


--
-- TOC entry 4712 (class 2606 OID 16738)
-- Name: il_bilgileri il_bilgileri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.il_bilgileri
    ADD CONSTRAINT il_bilgileri_pkey PRIMARY KEY (il_id);


--
-- TOC entry 4714 (class 2606 OID 16743)
-- Name: ilce_bilgileri ilce_bilgileri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilce_bilgileri
    ADD CONSTRAINT ilce_bilgileri_pkey PRIMARY KEY (ilce_id);


--
-- TOC entry 4707 (class 2606 OID 16728)
-- Name: iletisim_bilgileri iletisim_bilgileri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.iletisim_bilgileri
    ADD CONSTRAINT iletisim_bilgileri_pkey PRIMARY KEY (iletisim_id);


--
-- TOC entry 4731 (class 2606 OID 16829)
-- Name: maas_bilgileri maas_bilgileri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maas_bilgileri
    ADD CONSTRAINT maas_bilgileri_pkey PRIMARY KEY (maas_id);


--
-- TOC entry 4728 (class 2606 OID 16824)
-- Name: maas_odeme_durumu maas_odeme_durumu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maas_odeme_durumu
    ADD CONSTRAINT maas_odeme_durumu_pkey PRIMARY KEY (odeme_durumu_id);


--
-- TOC entry 4704 (class 2606 OID 16723)
-- Name: personel personel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel
    ADD CONSTRAINT personel_pkey PRIMARY KEY (personel_id);


--
-- TOC entry 4723 (class 2606 OID 16791)
-- Name: vardiyalar personel_vardiyalari_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vardiyalar
    ADD CONSTRAINT personel_vardiyalari_pkey PRIMARY KEY (vardiya_id);


--
-- TOC entry 4726 (class 2606 OID 16796)
-- Name: personel_vardiyalari personel_vardiyalari_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel_vardiyalari
    ADD CONSTRAINT personel_vardiyalari_pkey1 PRIMARY KEY (vardiya_id, personel_id);


--
-- TOC entry 4719 (class 2606 OID 16770)
-- Name: personel_yakini personel_yakini_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel_yakini
    ADD CONSTRAINT personel_yakini_pkey PRIMARY KEY (personel_yakini_id);


--
-- TOC entry 4738 (class 2606 OID 16866)
-- Name: teknisyen teknisyen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teknisyen
    ADD CONSTRAINT teknisyen_pkey PRIMARY KEY (personel_id);


--
-- TOC entry 4710 (class 2606 OID 16733)
-- Name: ulke_bilgileri ulke_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ulke_bilgileri
    ADD CONSTRAINT ulke_pkey PRIMARY KEY (ulke_id);


--
-- TOC entry 4736 (class 2606 OID 16855)
-- Name: uzmanlik_alani uzmanlik_alani_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.uzmanlik_alani
    ADD CONSTRAINT uzmanlik_alani_pkey PRIMARY KEY (uzmanlik_id);


--
-- TOC entry 4701 (class 1259 OID 16819)
-- Name: fki_cinsiyet_id_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_cinsiyet_id_fk ON public.personel USING btree (cinsiyet_id);


--
-- TOC entry 4708 (class 1259 OID 16754)
-- Name: fki_il_id_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_il_id_fk ON public.ulke_bilgileri USING btree (il_id);


--
-- TOC entry 4702 (class 1259 OID 16813)
-- Name: fki_iletisim_bilgileri_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_iletisim_bilgileri_fk ON public.personel USING btree (iletisim_bilgileri_id);


--
-- TOC entry 4729 (class 1259 OID 16835)
-- Name: fki_odeme_durumu_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_odeme_durumu_fk ON public.maas_bilgileri USING btree (odeme_durumu_id);


--
-- TOC entry 4717 (class 1259 OID 16776)
-- Name: fki_personel_id_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_personel_id_fk ON public.personel_yakini USING btree (personel_yakini_id);


--
-- TOC entry 4705 (class 1259 OID 16760)
-- Name: fki_ulke_id_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_ulke_id_fk ON public.iletisim_bilgileri USING btree (ulke_id);


--
-- TOC entry 4734 (class 1259 OID 16861)
-- Name: fki_uzmanlik_id_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_uzmanlik_id_fk ON public.doktor USING btree (uzmanlik_id);


--
-- TOC entry 4724 (class 1259 OID 16807)
-- Name: fki_vardiya_id_fk; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_vardiya_id_fk ON public.personel_vardiyalari USING btree (vardiya_id);


--
-- TOC entry 4759 (class 2620 OID 16915)
-- Name: hastane_harcamalari kontrol_harcama_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER kontrol_harcama_trigger AFTER INSERT OR DELETE OR UPDATE ON public.hastane_harcamalari FOR EACH ROW EXECUTE FUNCTION public.kontrol_harcama_toplami();


--
-- TOC entry 4760 (class 2620 OID 16918)
-- Name: maas_bilgileri kontrol_maas_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER kontrol_maas_trigger BEFORE INSERT OR UPDATE ON public.maas_bilgileri FOR EACH ROW EXECUTE FUNCTION public.kontrol_maas_tutari();


--
-- TOC entry 4757 (class 2620 OID 16913)
-- Name: personel personel_eklemden_once; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER personel_eklemden_once BEFORE INSERT ON public.personel FOR EACH ROW EXECUTE FUNCTION public.personel_sayisi_kontrolu();


--
-- TOC entry 4758 (class 2620 OID 16909)
-- Name: personel yas_kontrolu; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER yas_kontrolu AFTER INSERT ON public.personel FOR EACH ROW EXECUTE FUNCTION public.yas_kontrolu();


--
-- TOC entry 4741 (class 2606 OID 16814)
-- Name: personel cinsiyet_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel
    ADD CONSTRAINT cinsiyet_id_fk FOREIGN KEY (cinsiyet_id) REFERENCES public.cinsiyet(cinsiyet_id) NOT VALID;


--
-- TOC entry 4744 (class 2606 OID 16749)
-- Name: ulke_bilgileri il_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ulke_bilgileri
    ADD CONSTRAINT il_id_fk FOREIGN KEY (il_id) REFERENCES public.il_bilgileri(il_id) NOT VALID;


--
-- TOC entry 4745 (class 2606 OID 16744)
-- Name: il_bilgileri ilce_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.il_bilgileri
    ADD CONSTRAINT ilce_id_fk FOREIGN KEY (ilce_id) REFERENCES public.ilce_bilgileri(ilce_id) NOT VALID;


--
-- TOC entry 4742 (class 2606 OID 16808)
-- Name: personel iletisim_bilgileri_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel
    ADD CONSTRAINT iletisim_bilgileri_fk FOREIGN KEY (iletisim_bilgileri_id) REFERENCES public.iletisim_bilgileri(iletisim_id) NOT VALID;


--
-- TOC entry 4750 (class 2606 OID 16830)
-- Name: maas_bilgileri odeme_durumu_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maas_bilgileri
    ADD CONSTRAINT odeme_durumu_fk FOREIGN KEY (odeme_durumu_id) REFERENCES public.maas_odeme_durumu(odeme_durumu_id) NOT VALID;


--
-- TOC entry 4746 (class 2606 OID 16771)
-- Name: personel_yakini personel_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel_yakini
    ADD CONSTRAINT personel_id_fk FOREIGN KEY (personel_yakini_id) REFERENCES public.personel(personel_id) NOT VALID;


--
-- TOC entry 4747 (class 2606 OID 16782)
-- Name: hastane_harcamalari personel_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hastane_harcamalari
    ADD CONSTRAINT personel_id_fk FOREIGN KEY (personel_id) REFERENCES public.personel(personel_id) NOT VALID;


--
-- TOC entry 4748 (class 2606 OID 16797)
-- Name: personel_vardiyalari personel_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel_vardiyalari
    ADD CONSTRAINT personel_id_fk FOREIGN KEY (personel_id) REFERENCES public.personel(personel_id) NOT VALID;


--
-- TOC entry 4751 (class 2606 OID 16846)
-- Name: doktor personel_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doktor
    ADD CONSTRAINT personel_id_fk FOREIGN KEY (personel_id) REFERENCES public.personel(personel_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 4753 (class 2606 OID 16867)
-- Name: teknisyen personel_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teknisyen
    ADD CONSTRAINT personel_id_fk FOREIGN KEY (personel_id) REFERENCES public.personel(personel_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 4755 (class 2606 OID 16882)
-- Name: hemsire personel_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hemsire
    ADD CONSTRAINT personel_id_fk FOREIGN KEY (personel_id) REFERENCES public.personel(personel_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 4743 (class 2606 OID 16755)
-- Name: iletisim_bilgileri ulke_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.iletisim_bilgileri
    ADD CONSTRAINT ulke_id_fk FOREIGN KEY (ulke_id) REFERENCES public.ulke_bilgileri(ulke_id) NOT VALID;


--
-- TOC entry 4752 (class 2606 OID 16856)
-- Name: doktor uzmanlik_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doktor
    ADD CONSTRAINT uzmanlik_id_fk FOREIGN KEY (uzmanlik_id) REFERENCES public.uzmanlik_alani(uzmanlik_id) NOT VALID;


--
-- TOC entry 4754 (class 2606 OID 16872)
-- Name: teknisyen uzmanlik_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teknisyen
    ADD CONSTRAINT uzmanlik_id_fk FOREIGN KEY (uzmanlik_id) REFERENCES public.uzmanlik_alani(uzmanlik_id) NOT VALID;


--
-- TOC entry 4756 (class 2606 OID 16887)
-- Name: hemsire uzmanlik_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hemsire
    ADD CONSTRAINT uzmanlik_id_fk FOREIGN KEY (uzmanlik_id) REFERENCES public.uzmanlik_alani(uzmanlik_id) NOT VALID;


--
-- TOC entry 4749 (class 2606 OID 16802)
-- Name: personel_vardiyalari vardiya_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personel_vardiyalari
    ADD CONSTRAINT vardiya_id_fk FOREIGN KEY (vardiya_id) REFERENCES public.vardiyalar(vardiya_id) NOT VALID;


-- Completed on 2023-12-26 05:48:37

--
-- PostgreSQL database dump complete
--

