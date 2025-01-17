PGDMP                    	    {            mqttbase    16.0    16.0     �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16397    mqttbase    DATABASE     �   CREATE DATABASE mqttbase WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
    DROP DATABASE mqttbase;
                postgres    false            �            1255    16738 "   actualizar_vistas_materializadas() 	   PROCEDURE       CREATE PROCEDURE public.actualizar_vistas_materializadas()
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Actualizar la vista materializada para sumatorias diarias
  REFRESH MATERIALIZED VIEW sumatoria_diaria;
  
  -- Actualizar la vista materializada para sumatorias semanales
  REFRESH MATERIALIZED VIEW sum_semanal;

  -- Actualizar la vista materializada para sumatorias mensuales
  REFRESH MATERIALIZED VIEW sum_mensual;

  -- Actualizar la vista materializada para sumatorias anuales
  REFRESH MATERIALIZED VIEW sum_anual;
END;
$$;
 :   DROP PROCEDURE public.actualizar_vistas_materializadas();
       public          postgres    false            �            1255    16425    calcularDias() 	   PROCEDURE     /  CREATE PROCEDURE public."calcularDias"()
    LANGUAGE sql
    AS $_$CREATE OR REPLACE PROCEDURE calcular_suma_por_dia()
LANGUAGE plpgsql
AS $$
DECLARE
    dia_actual DATE;
BEGIN
    FOR dia_actual IN
        SELECT DISTINCT DATE_TRUNC('day', register_date) AS dia
        FROM sensor1
    LOOP
        INSERT INTO resultados_diarios (dia, suma_diaria)
        SELECT
            dia_actual,
            SUM(kw) AS suma_diaria
        FROM
            sensor1
        WHERE
            DATE_TRUNC('day', register_date) = dia_actual;
    END LOOP;
END;
$$;$_$;
 (   DROP PROCEDURE public."calcularDias"();
       public          postgres    false            �            1255    16426 
   suma_dia() 	   PROCEDURE     �  CREATE PROCEDURE public.suma_dia()
    LANGUAGE plpgsql
    AS $$
DECLARE
    dia_actual DATE;
BEGIN
    FOR dia_actual IN
        SELECT DISTINCT DATE_TRUNC('day', register_date) AS dia
        FROM sensor1
    LOOP
        INSERT INTO resultados_diarios (dia, suma_diaria)
        SELECT
            dia_actual,
            SUM(kw) AS suma_diaria
        FROM
            sensor1
        WHERE
            DATE_TRUNC('day', register_date) = dia_actual;
    END LOOP;
END;
$$;
 "   DROP PROCEDURE public.suma_dia();
       public          postgres    false            �            1259    16409    sensor1    TABLE     �   CREATE TABLE public.sensor1 (
    id integer NOT NULL,
    register_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    kw double precision NOT NULL,
    ah double precision
);
    DROP TABLE public.sensor1;
       public         heap    postgres    false            �            1259    16408    sensor1_id_seq    SEQUENCE     �   CREATE SEQUENCE public.sensor1_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.sensor1_id_seq;
       public          postgres    false    216            �           0    0    sensor1_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.sensor1_id_seq OWNED BY public.sensor1.id;
          public          postgres    false    215            �            1259    16538    sumatoria_diaria    MATERIALIZED VIEW     �   CREATE MATERIALIZED VIEW public.sumatoria_diaria AS
 SELECT date(register_date) AS fecha,
    sum(kw) AS sum_kw
   FROM public.sensor1
  GROUP BY (date(register_date))
  WITH NO DATA;
 0   DROP MATERIALIZED VIEW public.sumatoria_diaria;
       public         heap    postgres    false    216    216            �            1259    16718    sum_mensual    MATERIALIZED VIEW       CREATE MATERIALIZED VIEW public.sum_mensual AS
 SELECT date_trunc('month'::text, (fecha)::timestamp with time zone) AS mes,
    sum(sum_kw) AS sum_kw_mensual
   FROM public.sumatoria_diaria
  GROUP BY (date_trunc('month'::text, (fecha)::timestamp with time zone))
  WITH NO DATA;
 +   DROP MATERIALIZED VIEW public.sum_mensual;
       public         heap    postgres    false    217    217            �            1259    16728 	   sum_anual    MATERIALIZED VIEW     �   CREATE MATERIALIZED VIEW public.sum_anual AS
 SELECT date_trunc('year'::text, mes) AS anio,
    sum(sum_kw_mensual) AS sum_kw_anual
   FROM public.sum_mensual
  GROUP BY (date_trunc('year'::text, mes))
  WITH NO DATA;
 )   DROP MATERIALIZED VIEW public.sum_anual;
       public         heap    postgres    false    219    219            �            1259    16704    sum_semanal    MATERIALIZED VIEW       CREATE MATERIALIZED VIEW public.sum_semanal AS
 SELECT date_trunc('week'::text, (fecha)::timestamp with time zone) AS semana,
    sum(sum_kw) AS sum_kw
   FROM public.sumatoria_diaria
  GROUP BY (date_trunc('week'::text, (fecha)::timestamp with time zone))
  WITH NO DATA;
 +   DROP MATERIALIZED VIEW public.sum_semanal;
       public         heap    postgres    false    217    217            -           2604    16412 
   sensor1 id    DEFAULT     h   ALTER TABLE ONLY public.sensor1 ALTER COLUMN id SET DEFAULT nextval('public.sensor1_id_seq'::regclass);
 9   ALTER TABLE public.sensor1 ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    216    215    216            �          0    16409    sensor1 
   TABLE DATA           <   COPY public.sensor1 (id, register_date, kw, ah) FROM stdin;
    public          postgres    false    216   �       �           0    0    sensor1_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.sensor1_id_seq', 1261, true);
          public          postgres    false    215            0           2606    16415    sensor1 sensor1_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.sensor1
    ADD CONSTRAINT sensor1_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.sensor1 DROP CONSTRAINT sensor1_pkey;
       public            postgres    false    216            �           0    16538    sumatoria_diaria    MATERIALIZED VIEW DATA     3   REFRESH MATERIALIZED VIEW public.sumatoria_diaria;
          public          postgres    false    217    4811            �           0    16718    sum_mensual    MATERIALIZED VIEW DATA     .   REFRESH MATERIALIZED VIEW public.sum_mensual;
          public          postgres    false    219    4806    4811            �           0    16728 	   sum_anual    MATERIALIZED VIEW DATA     ,   REFRESH MATERIALIZED VIEW public.sum_anual;
          public          postgres    false    220    4808    4806    4811            �           0    16704    sum_semanal    MATERIALIZED VIEW DATA     .   REFRESH MATERIALIZED VIEW public.sum_semanal;
          public          postgres    false    218    4806    4811            �      x�l�k�%;�����5�;�����?���¢�2���N���f4�
E[�O+����e��j�����ݿc�9Ο�w�qv���:�Z[?ڳ�s�ܻ�R���=�w�:Yd�����~���裖5�l��RGg�qG;�{�l�i��X�����>�$��uJ����UN�KQ�Zc=֘�C���ew=�*����h��O����Kk���o�^����mg��G�,{Wog�~G��t^�<��쭳�=w���^s�/os�z���������E��=��Z�7fӶ���<U?�۴]{��he��ؒS�h[�[��[�Y�^��R�3jk�/����:���>Ѿ}�M9�����q��dL�c���2F�[���"�س��dʼj�C[0���lf_���N��u�cm�=��$C�V߷]�Wo�}�)�>}�2��"�^��TmE��P��[�6��V𓮷чZK6P'�z��j��5�hg�W��z���n]�\m���8Wk$s��oӟ��_�[/�O0���0,�N��͢��S$c�
�oӟ�<�(��n��ŏ��P��hG�nkj�d�Z��m�[���v��v�l���:ķm��#g�tj��V��t�X��[��C�O�6/���28y����Sm�R�Uo���Xw���;l�2���1��ee�a�M{��6)��ʋhW�umx��C/�\�\�y�jӶ|��s���u��u���K���U�z�*�*�ހ���?Xڃ�I��\�֝��@m�}Xj�k��l�F����C��g�k��K���ÃzG������6��>�2:�l��:1�a�}��i�Y��Ѫ�粔i}�|�o��o?��X��":&|���䎴K.-ֽG��9�-ǦE��/ۿ}R��h�)�Y����躧|]�T>��Z�P��+xU�Ũח^�E�*�V���i������)�*>��������;2�U��挪5�:���S���%%;����辴���c�m0�ִ��X��u�Y+�y����e+�X�}e=�,U?�;�/k���m+.�E��A��nc��Ω-���d�<�Ua������S�%׶e���%�^W;5����cU�u����YU�x-]ú��Zq�ϥ��E֪0@�� dDG��En�Nqɼ���:{+"�cU�����]��Z���_V_���Kw���N����6�������bؾ6epr��n�X���H�:�Wα+"�V�3붰�ݭ=><���>nM�:��h�yr�%7��:9T��M_�z]dZ"Y� �.����צXl8(Rh ��*��5�  P`U�U�Gf��\��z��lʥ��<V��	�����]����.M6NM���m�&�:j2���?��1pl�8��֧,c���d�Ó$;\�Z�z������`��궝�Kv"$\��$;��C�Q��Zr�D.wyG8�
lp���%��  �?���s��u�d�!W��O9}E3�U���tp�붽q�t0����~���#�}���N �7ߏ�봉�t���7Dg��(�P��u`��P��E��
�~���{}yY��q�����X�UP�]�
=g�K�z'����SU �`��19Rm�bR=�o�B,�v�5U�{{������֖^ٔ��Qd��I�H�=��M{k� �����j�Tp��0I���M�></�U S�o��`���VU��^��ǟ�+hKu,����w���-��i�u�ɭ�
�N�"S���`�L�*��G�1\�pwĬ��E�:+�$-�U]���]FU�;u�W"o�L�R�%5Eg�=Lu~(��Y[2)���a���A�K��ut��Ru���w#�Ur��л�zYeK�ՍhmN����T]��
㪯D�2w=��+�Y�����-mj�.���J�{��K*�����֟�+B�<,U�?1��/�,h,E���"5���}/k�W����Ru�k�al��`���u]Ω�[�cg�a������4�l!#Ңݡ�,T��\G�y�n��E��۔���땨r��[�K9�y��E��_��Q
|h�~����&��,��a����ȶ�ҝVf��^�݁�!����5��N����2|�����uJ� x��}K!�X'��������l�i�e����(�r�s�u[h�d��@Ċ��=+�JqDi��U�i��)���Z'�"��u��D��b��k�m"9�\�M�X'1 ����.%�*�,�WӍ�kO��8y#�$�9�F����ƗRL��U��9f���H�:	�9�?�0�	EU��#��m�8N��r��MM�:� ���v,�[2py%�CZ�0��8Q�H�:	�?��2�&97�֫�_Q24u�6&Y�$�gV��pP�BA���Q�h��"fbb��a���uM�>6;t�ȣ�ʋ ����Sa��	?=�c��W�pZuq���8V���!ޤ�uɋ*nd>LU�B��dN>UW%O�˳:���Yé�)�"[U@n?o��{I������!�xe�r�?n^�RB]����u��4�+<U�>ɭ?u�����E�#��g_d���f�~�����ʻ�t�:kU��uh��������(�B4�z��8$E�a����Dx��+gA5N��9Uġ8Inε�\�5���ڜyȑ��Vb�	�2��/rj&Z�a�
���m%�FiK�x��P!"S�6s�q�݁�nᙾ8Q ��y�8���W?�_�\�Ff>�k~ܛ��I�,��f͹��PnJk��OSο5�j�}ZW!�Q�<�܏�^���Qv���x��XD����m�����|�b���b!Wn��ce�^�w}�I0�M��$'݃�Jn�����k(:�C��z���~��a^9}E%
����,�+�ά����T��8'�fZa���Q��?>��[���1��붕���R��u����+2�[��Ǉ�kLX����� (-Si��Mh#�%��&u��|H����"5*^J�9sr�-b]��X>���E����	�[���P��Օ������-�����U�#:s�y+��7��ǻ;ÑG����`����SՆ�;�����)�������y�ZZw�6[�y=|����Ş\� WNsɫ�N�$:��篯�O�~��ebG�>���[������SW�z��IM�E�O'�*��:��c�Qb�;P;D�TK<�bճ(q��"X�P�?�r�[-o�D��x8TŪr�;"(�R���t�vkWI��n=-��Uu'���K� ��hŅAڊ��t%b=��"UAaڊЈZ�)����"�,O�q���0ɡ.B�K�ק��H^@�kϾu�7��R���}'K]Ī
yF,�(�qGȯƵ+���8F����H��U/PW�mR�ԣS�� H�nvF�-��N���U��J�"�*,R��)�����LS�E�;��V��U�w�eh:�6�o�	'Qcc[3���U�7l����*顏�.q��6u`-��u�^�3U�y->������W�0)W��H��E�J�^��qz�y���Ld�8Uj�r�����"\ՓD�wR��-<��Em�n�
�@��E��.���:��.>G��#l`@I��HBD��a���������1�p��Mܻ|���f^]���L�K��,��!A���8�`gU׉�D2��E��p�(#�{����u��Ny-��v������sY dk�+�.���s�2�����L��ql���|9���BA��tp2��5��p�KlG���]�سM�9%r�N���U�1��"�S��k�ʴzZnW�"g7�U���g|^%�����2*E\�ro�p:5C��U��=%5��W��h�����i��(qOdtu��(@;-p2E.�.�f��_�2��rjZ�a����3u�)�T�;�m@�&u^FG��3��E�_ �V
�����)\s�(���zR]�2���j��4����\(ֽa��9�%�P�emmjW����� ��@;�7���L�]�2t�	Gdd\]�3�_�����C�H�곫K���h96-��ٔזV|��w��$�m�'d�
G��fpU�hO���<�A�N�ߨ�G �$C��`���N�    �i]�=>F�'ѱS֫�[�E�:;��<�b��5�@�]J�:@/��FFW�����N9��
8�|���@X���tw�t�2��5�_����Et�/���*��^���#�k���j�A&b<�	�yQn��#Ш��.�`�odtU�,-�� ������4����pn@Lk$c�Gۯ(o��UXlF�m��\��^nA�$c��S���YnD��^�L�E�=���\#��:RWk$k��5���BMJ�LC��S[Ѷ4�gZ$Y�F�Nd0�O����O�*z0h���U-���P���b��K%��)؃��0�C��72��E�_ν�\�*ܑ�2��F��`*���������V5y(�S,��,{��X�vq���j��������\�p�:�V���s�n�$#�Zd��Y�>��K ����L�d�RA��g�u@˨��\6ƚb����K�G�rx���*P�Ţ��_�T�nu���K7���5���`t��)�{��^���E֧,C�,U����a�M����t�
f��+�[��\D>��A�MС?�h�@K���Aي�䠏>K��xX�� ���/BB7�!���T�NU�#?���"kU��X�H#���2v0��	�:�
(~#ì�@ տ!W�*R%t_�W&�c ;�_ j���n��Ӄ��@]O�_KqΔՀ2(�Ѿf�u��� 芟��I\Е��K6�	�N�Y7���|��7B]u�z�����榐�E֪X``��Adzȅ�|��~ ����J����M,������������XR&C��y����Y�j��9u-��)8O1oCn��F}���nbY�pr(�N���&�	�Z<E�Y7���qB�e�<���nc��.�p-�l��VPr͉ �j�n+�Hk��m���I~#ì�8 `�GT��z����]T�c.�8N��g����(����vy/y�~�]S���p��&d=D���ؗ��=�$�e�̦�L����]K$+=� �cA�� Q�����>ר6�4����b ]Qu<�??9K�:
Npp��n]JGF�X1��E��{ �pk/o�+m����1�C�@Q|W�C�}e�qI��О��B2�z��:P��=�1����S(�+d�d�� `���)�G�IAQn0���rv�M�M��C`*V�v���L���L�
��C+�ѢE��`M��`{�"ʃ*n�X�n��Zx���*X�/�h��)G�p�y���,���%��#���@��xuwr�*�(�:�	lJ���eȍ8"���@qSw%�stԛ�e�/� Êe�Z�a�� Xñ���RTD��/="�������h���* �D ��+�35y��h_�T����"kU���w5`���5��\�C�عz3�z��w��X'��覽��D�ބl݈J���Z�f�>��]��� "�	�������b �x�
(�� 6ߕ;����eƪ��FNyU��<(�;��z�jM9{��a�
6 S0o�Q��Մ?�`;( @XI�Y!�>�r6u��u!�|�W�
U*7=GFY��,�LL�q�"m�ͼm7���)tj2�z `"H�͍Z��kw]R�!9���G/��� `�6�s��q�{W��Ө�3�����}��mݝBM���5��b�e�� @�϶��_L���M��v�2p�\��"[U u�-�'����)�z��uc���* ҍJa~��]r}l�M�W���i�d�� '>�V'�vO|^
�#����2]Xc�DGy^xX�_�B�2
�L��n�@G'/�W�0�.[�e�V�u՟����9��^]� @'���E=P����ƴ;�.��od��P.����6X�t	���w+d���F2�K ��[B/��0�!{7�urʩ�F�}�ѫKp��"��/�)-q��F�
�"=��l���7;0ց9�����ؕXP�/Xj�.1 W�n.�u�t׊L�a�r�P��76$��%�4庆Y����>=F���ӘƦE��  `)b+���k�f��T�\=�f���3zu	tŇ�Bs��@o�CC�eR���3zu	��CN'Q^ӑ�p{�Ȅ�C�w��"cUp�.M���v	�����.J�([�p��F��.̓B�f7�/S��g\�#W�H:�LE'�Wv�����~���=h1�L#&dۍ�f���n�;�+�I�0l�#�}�W���2a��d���n��N�%v�T	�Ć�$�O>"?������(�5beyW����C��od���p��F�������F�A��]��dm�|3zuMqX3Zgh�Ϊ�U	���	�x�I��ѫk�îQ��2�(U�n�+KOJ�U�3zu���9�(��J��w���*P�`����s���\�&�p*���pzGmj��.�>�(�R�E�)'�A4��]�J�,$#WD��U.�.�(%.�����C{�vDg&#WH_��u�z�3F?#���77=8��,AX�����T��(���A*H3���?L��y �^]7�*�
�Ǹd���#b�{!��'H_[�U�Pe�<m7V��[��^r>j����|5��P����h;���p��G��~Ty�>�W,����
� G���#}M[�F6u�,*4	�bm������e�����Eh\�˺����"�Xh�v_��]ȏ�T���^6��<!X,����Z�u8��4���t��"��H �֨D?�q�j��l}T�iv$��Ӄؕ�P1N�h_�a�ë���@N��R;��.Q]|Z��5�_�|?~S�R�Z#x�#��L8�p�Xc��s�觓#�f�m~��u�u8�8e�	�b����s�
o4/�~W���:�}��Z�a������O���\�3$U�ˡ
Q˦�ջ��V�P	E	l��>��y�9:�
�]��̈́`�����xE�O�B�����Rt�	�bm+�F���G �_�2a:e���L k\(�����i���ܞFI0�6�7~�5�B�A�j�e�t�� ���{+K��o&��5:kD��&#A �V>���& X�Z�a���^y�a ���+pG
�ϱ�UZ	8g��X��^}���R����G����˃E���흁�B��m W�ڷ/�ˀ�t��Pؒ���sD)__2�\IW<�^�����Z�a�t��J	T�Si�KK ~/Dυ����3�W,2�����[��4'����ji�e�/�<��6�6㜁�*�Fw����F�~�%CK�k\������Q7���Bos���:6�;G��o&�J�Іj:U$��,:()O|95IŴ��->z�"�W�#��W�b�ADѿDy? O9O�<̕>T](��i�����Jڕ4_)�a��\�L �l �m�	�h���h���F�(K��Q�Ȗ<̕FT�!v_�g���m���n�0eү��	��՝�Q/��L��TH��龠a�Z!�D��J ')H�zdh,���0��jX���ۣ%�EhE�/�&�,�f�h�7 (����$�W,��g=�a���#>7d��UG!I�N��\���M9�=�3}��/�:��D����+-B;�n�`��.W��B���~3�W,ҭ�(Qqw���%v�Hl���o&�%��
]yV���U�+����Sr������H�Zݍ���]�h/�Csx
wM^�&�ju3�l�HiY&u�y�~9��}&@��	��TzQ7��]���ҁ=rO8�U��xK�J/*���Ls9�Bv���4���!��,ѦR�h�3�bʙ�38��`����
ήE�J3*wc����4��rF�?�y���C�<l�nT��i�F������Q� cv�tӖ$Kk��G���4^h�#LU��b�nSZ�X�a�t�r5��-Ŋ���I�%A�Xh�d�L�L,��Nh���L�5
H������<�����Q+��тi\��CN�&o]"���Xݍ�����R�F{���9$�t��"4��5�F�pθ��B2,_$�S�O�/����V��&���    a�E�F4�w���U��i�X�n����^���$�nԱ�RZ�a��FEĉ������ю� ƀ@�̄_�~����AR�pu̒�S�NT���3X�F7j���`N�.IP����-��W�?o�X�ۺ#W젵�4�0�c�E�b�}����PiFՓG����z���P��i��Hވ�y*ͨ����Z�لI���q�,!��]}�*���~�s�}����"�m���e�7~5[4�BR��,�����d��q6D�A��	�b�&W\� ĕ^Ce2���|�D�����	�bm+���a��!��W��l2u�M��ԷI �l��c�^���3���1����`$�W�q���_��`��-#�S@V=�����"�X!�n����;����L���еk[��"�')��L
$hQ(R�-��)��R���`���r�=�Uǃ�qŖ�FLѼ/'� ,���B�h'��<�1��k.���o&�E�AN�
��5�*����]���V?��X��&��k�v#
�Άh�EM���	�b�*��c �����)�`�jt��~3X,�]=`��&*�%�"�/0R�I��M��"k������\3���8�?3-�~3!X�j�r\x��f"��
��.4���u�aM�<�7�gT��)������N�,h�b���v��v��ձ;Pő(���8�E�S�"cU��V�!��r�b�'G� )ϩ�}����Z��AІ[�i���a�Jv��:5	Ún{�(6�e$ϩL�ԾA�8uP"����0W�Q��5���A�h�o�OY��L �t�#",��NK6(Ҳ��[,0��ґT� ���G�mۈ����w��^��bơ�%���T��� �ӫ*ݬ���������K �t�#�y�L�wF�Q�F�Vq��:�5�W����]��I�v�_�4k��x��yت� ��!����Tz�%���䡯��_YH¯��)�H[T�m9-�|�� `�Cf��5�L	�*�F6�qx_���P�?����	�����7C�6�m�Z�ӗ髚,M���E��Z�RA���z�
�F�EX,0ݞZ"j�/t��)a U���~ŵ�4$�Pei���+�X��k�0����_A\ߙ�xNmhS~�"�o���C�}Rm��rha\�(��$�Jk����� ��RKRT$�J@�n,�L�X��L����IG����(4z)d�	�b�A�[?f �-+���Oh,�r�t_?H���O�^��Q��6
sAL���U����N �h[Q�8֡��.+�>'�k�.� ,-�
�`���4�u����t�\*�ݝ{l��X�S�.��S�h��4�hB��2}y�k0?�~�[�fʛtc�C��U	�\&���O_c+��P�)4�!׆b(L
�,�0���P�>@
q"����^�B	���5�Wv_�J�0�?� %�[�W:������xXko�Ҕ�z\��5T2A����0�*z4��
Z�f{�B޷C}o��a�}�5� �\J����P�I�>PJ�����ѫ���?ړܝ3Il�H]	""Y�b-��Q�DdRp�P�B���0"�p>�P���PG�k)_�39:'����A����:u�2v����!v�,����Ⱥ����6�^���U�٧۵E)�g:@ؐ�.u-_&���qZ�a��������`e�E��b_�7,��Y��(��΁Ek��;�KAM�����U�ׇP4 �@���{����B���r��E�:�1�n`�Y܁��l�7;�+�Z�a�S�����1�h�k\�6B�e��G���[��� �ٸud;rr�U�7+�Db÷DiZ$���eh��}Η��P����s��r�+CW^�܃!	 H��,_�@��ے=�B2�A `E�/R�P�Pr�Ml�ٌ�.�0��V� m��c��)�(�J��u`=Ro���Vƭ }f����#?^-��@[C*Q:�+W���f�A�U�$����6�F&"�.+˸�   �J�(�¥�ۛV��P�ݕq��?�2�cտP�1ܲ"�]ܙ&���P�����E��@��B��&%]ܛk}�P3j5��G]7k@��8��ۘf7��n��a����KO��X����*�5v��E�`Z�a���AV�/�D��V�+r"j�tp����d�jp�Jk�k�H�J�-x?�@����&e"�\�n�^:����@	����x�>.2��Zn}��J�V� ��BB��=�xY1�?�V����l���/�R:�?2�6K�Κ6j-�0V�����.�f����A;�\�/�O�0�ζ�����b`�_VD���	7��2n5��1x� �(9�6j�� �7��Ԯ~+W�~�b&��}�qpj�zQoH�j�����g�n;ā�p��D7��n������p{܈PQ���k��zߍf6���)X��ާk�5g\�����۹I������VF�����UmP�����$�%D��Ð�oe�j���*����GEa2\ɡ��R�h�jW3p5��SS�x��!�Ʊ�ʃ
�����Ո�/������s�<�)#@���M�����>�.}f��M��tDl��n>�a����B\`����l�/wD�r>����V�����<��4�rk��ס���#Q�ܖ3�I��N7�q�{���㾬�UJ{WK �\Mw���c������Z���� XY2��?Re;4تV�"*��__&�Yt�2p5��G�����C5���/X��W"�2t5��z���ڰ̨w��� M�0�8������=�� +Y����+ff:C1���q�I�c�O��~�N��m���'53n5��ǡ�c%�H���)n��,���~$S�n�C�4�=	J�s��I��]YD$��F�������+��d���c;.]����Ni���C�u��;{ם�����N�[����khu�@(B�cM�O�p�b\�7�a�����Rn��O�T���3G��d�j������iP��w���%6=�-xc�H������	�~ThG���Q�`H�J.9�[Mb��7�{�.�_@�H,�0H��VF�&!�B�kã,�o�! �t4��ՌZMB �D�$J\0PҨ����A>�9֖�d�j���nC^��F�� �Q!!��y�*�}uF���5[.�5��./�O6"����n��E��S"rdU4���(�V����� k�LF��~x�Y3Xi?C.�@3 �˨�tw�8���Ƃ�n=BX�M� y��Q����q��
�����04)ʡ>�@@�<���>r�?��d��Nnr]��_�~~+�V3��(����K�1-���b��y��i2j5� �)�ѡ���L����OL�<C�*k<�U���%��<71s{�x�� I�wkF�������>��D5������i�;k�������;r�k�����T���#��<G2����9�3���[�@�����ȰB����>�qyc�0z�-[4A1���p���V��{�ccl Pnak��?
N������ʀ�roOk'��F�N5�ɸ^�-HQ����X-������\2�f����/�̉Щ��f�j�����%�D)���1��U��2b���wϧ�nZ�ż���DHR|�X-��_l��rǟ�6�tA�����g�j�������5L`@��)��;�����X- ��F���-A^��f�2��g�j���W�?�	�0y���i4(4٪LF����(�xdk�F�V ߺOQ�vn��<Lս}#T
��&Yi��W1t�^L�f�jEk_& ����M'x��O(����ɐ����BI�H=h�����L�"�HƬ��w�t�L�OKE*��i����x���* ��7�U�d��Anl��0h�hf��J��]Хfx�Jq���a`NT�L[���SB� 9�q&D(kDD�|Q+rk�a����UiEq��d2d��w�55��-�    �C���ݗ���m7�(H��IH���Û��>F��򤇓���[ԁ���kh�[�Z��k�kd3 'l��h9[�4!Խ2^���g)x��*:]2�г��~RN?J����Zn�������aɏ�E��DN�?�U˝}H��	'�q��X��Wj����2X����]:pd4
�Yv���(+/.-�0�9����6�Jh&�G}��;UA¬��p��G���P-T�*2��qQ�`�0H�?�Lƫ>g޶�(x#S@k�Mk@;k�"d�j����JU7S>�����H�S-��uC���N*;�aZ��VC���٭���"�X7\>������^��c(�1��1����ΐ�v_m�Hk�3z!r�r����ΐ�v_����튈��m�b��F��Z�����F��� ]�e�Jwjי�
���Zm��5�k��4�(�	l� �~1h0R�3h���1/��K�K����nH_�P�M���P�����"fZ�4x44P�KL�;lH����^���:0/�o���*_�C�!����p�<�2F�vϗ�${��H(�B�����p�8=!�Kn�` ��jqj����;�V._u*iwĵg��N�K�Aml�>�vƭ��Jt�6��+���:�i�p}�^�q���eψ��u8N�'��{{��MzU�yXk�.u��ň07؉�~|������5�v��[��{�c�'�<�-@��~�u!<VWg/Wۭ}L�t�5�>h,�� n����u�Jo�t��9g�����	ey�=k������X��3_��6��H���l�|��;��E_r�٘c����JMs�ΰ�&Я��@F!t�+���z�M�0%�M�a��vIL�w>�sVܴF��I�t��8jK3l�� �7q�7z�+X���.P,5���[m� �A�m{�'���]b:!cAk;�V�(�Ѥ��u:�&0$B����7�En$�V�]}�4�t<������7������K,�T��@�]l��F�:"?���th���Pi��ψd��vc�W9�)X�Q����Pi�k�����_������FP#<[�0�POL�����E�Т*ҍ���pZ;CV�=}��I���?�h'u� Oc���og������P\
<H4�htG�V�����3bu���Et�q}����C�'���_�^;#V���Ç %2�``�I�V&���Yb 	p�0E N"/񕊙i`���I�z�ҧP!&�!aZ@	c���%w���:n�#���z�Ґ}���Abſ�Q��>n�0Vz� ϙc��l3Q�祘�.K˨�q_�7������pd����z��]��Z����1}$ye��Fw;";���P�og�긭�&'ߑ����l�H?r����e�긭��E��y���l�#�=L��;�A@��A ��1�>���;:E��
Ą�(+ɰ�!
�G:X���4�!e�n������a�݃�?R!ݚ��I�8�1L&ܴ���`��:�b����r.=Fd{���6������q[_	P�F��]�U���Hxᦘ4�:��C�>��K]h�����%oĢ��S�7�V�m}hzS���:��7�k�1��J�2��\��1�ҟa��6aG݊�ֳAg�|k���L��G1��P{�y��[EW>m�Z�a������,�}7]��_��L��`uX�2�:D�H�*<TG����˘ND]�~.-�T� ��W�T���`�0���!CͰ�!�H�GC�E_Lv��r,M�����Z�a��i�'Ʃ�0ӣ
z�@�d�6�1�r��:n�c�l����m��5��0�]����l��T0a<"�ɔy@]�mo1T/��e��:� �K�$�->L���A)ܨ%C�ؑd��  ���ÀY�:#�d����
p��D2�K0=��e�0��a�W�G��I/x�#Y�%� R��yQ�+AL]�٧qKr��Ψ�%
��̨3�I�eyA��0:0+`�I�z=c���F˨��_v�ǝ�ЭP��m�a���:���V�=����(���Ǆt~;�V�3&;���N��1C�]��3? ���ɰ���IV�u�2�4���).�c�xkR�[]� �%E�wfJ�~�˼uk�U,-�V� `��ux�=�̚���"�����������lD�	��MEM��x�����h���O�A�
��OB��PN cW�(`�o6�5`j7JxYJ���'uF�M����ₔ� E�m�P�<գ�)�蠾LƮ���eբ�cx1B㡴��@��t!�v����L�@&!;\����Ⱥ�j��a�1b2�/�D:�	��r�Ѡi��Z�a�1br���m�/�o,zR�����Gn��y�*=}@�A�	��7�[!���'�ټ��V=b@��vH�|n��"M�4���+Z�(cWV��XE{0eI��E@r�s�:;cW7f��h1F�w�[�j~e+�Ӥ����1�/&L�׏<���C��6�JE+?�/�����k�lz$�|+�+o��ɞ���v�����k*ttl�W���8��X.t�r�2�����X-{gDWt{{����AV�"2�>��^��WC�p�X:����e]�@,��[e��Z��O�E3�"��!hg��,$cW7�����eh��CQ6F^�'dJrP�~;�W7���8�E0�gO	.��l?�uK~��Ы�?�Bd 7�/`�DX�)!��(32@��+6�<֠U���+2P��pğH���},B�rO�wA?� @�Pl�vkЁ�u��iq���D'������ 
���®b���j���"&Cf}Ṁ�0��d��]y�"�1c�p��iF�H����!�"g�_�U,�=�0BMfR�3��0#�qc�>oі�vkhK�x��Mq����'A���x.��E�c�Q�v� ˠ%�zI�RMX�4dF���®�H�����f�K��qZh�R仟���K���0#��lTB�\Q��Ǥ�J�J��}�j��o�H��G7匉�\[��O
h,�0U���cN��D�B��b8M��iB�w��T��,B@��c�θg.�mf�2�o�В���TK�ރ�L��P]k<l��}{�C��*�I����B/�{�gNyX+���
���x�7����F�!����E���>XA����w$�W%q��h���;�a���Q߾a�(g ��j��#+w�`7��S�JS=Y-��c54�'�6�́�����f��K�C$��ߠ�/�,*3�Cej`��7à����*%� ꢣ�_�T�<��}���/�X7��'}������T�h�1�A��c����KN�~6FLU?�a����L�3^�/�+it
�VL�z���TO�kq�ʋl3���tO���K�J���Ker�$"@fd��(o�D��(�A�aJ��Ker�KhS�$/�	p(W$BEQ&�E�JS�W����Gie��i�|����NM�Z=��V��z�Ǣi�|s@��@-th�d�Ճ��B2ܬF����]{"�+�Ҧ���̵zr�����2�;s�ɻB@��H�*�n�S��V�+�z�ah�Ax�k� �R}�X��-k�ྵ#4#���TW\Ɠ���a�����znߞ+��u��= 0�2��h"��Ӓ�Vw��M���+� �![�f��A��p�"�V����D��T�j1� ���lf��\@��E��֘�7#�F]�0�L��5PҤ�)_Ԓ�Vw��U������Θ�Hyك�G3'n�=L��>�[���>Sh0�@�6L����N{�*M}L`v�
�O-�w�F�p͠eN���=�#�Jts�&�h4�'T]A���b�yX*#��u��P��=&wvs� �Ek�2�)��%4.)���#���F���n�*��'�ÐJ
oI�6CNO�����0Uz��\���i��M+{���RF6�|����K����0Fo� ��Z�ʺ5�=    ���yX*-}n���qW
m@��qmz<�O�)�Nتg�͐�@Jx  �!/��_���z`݇��m�H9��q��h�(�K����!D��_J����om�� �?L�}%�A�X��1�W1cF���Ȉ�FD��ꆾmc\)p�Q��(�����w�؍�����Ğ"?���ȵEU���߫5�J?�/��F��,%G����������*`�J<s>I������@��n\T�5�� �c2"1ǚv_)�yȒemѦ�m�JGhp�s�ؿ��l4��irQ�~g<L��>��.Z�RĢ��,�(FF���d��}(�D���$ݙ����4`��Lgrьd�-z�nPǁua��eU��fN��G��F���>����w4��|f|�O��R���4�V[t��f�^��D$8�A�{PP���Ծ3���h�!#I� �}�Q����0��t���l���o1s��@H��̉|��@1�º0���L����G�]D�Z���1��$B�t*��L�� ��]\��I2(�A0!8c�L�ߙ�V���ק>��/��C��n,�5�ęL�EK��8'Q���cw&��$f]q��F�>{��T��/&�B����\1�WM@E.��w��Ti����z�2�\4+ڗ��L�o���|�*M}m~UPB	�Q84��mP��9��|X+]}m�0������T\}8�Ysm��M��/:C��]�A�hQ����0Vz���4��L�q�:�!�����z+=}�Mㄞ 
}��DŎ�×Yc��o���D���za��/�W���KM�ƪ Bb ��=���ؓ� r�Ζ>l�3�G-�&��P�11q@�Bf$����0�A�䍫	x�r&<�Sb��)�Uk�
g=,u�(�br"�Z��D�����,з���w��R����;�T�
��9JD���FYo=,u�Q2��򶬊w��zY�A��;�a���ѩ4�:MFf�P���d
��f�I��X�[%��Ѻ90e*�#!G�,M6����>�%�Z±�Nq�A842�(�2g?l��}Po}kztQsv�c,p�@�as%�E�:��6��r�;Dx83����a�
 V�X���=�d�i��!$���2���v2�N � %Q 'O���� ��U
�xv��N�^e/���nN��b6�>4:��g's��������F�6 �2���)�c$�\-��v����Qԏ�
��٨�f���d��C����J�(O����21q"l\N�V��qv��ĝ����	�L�HŖ-��s��Z���� �	�e%�Bd���a�b�s��Z�O�T�V�
�A��<�a���G:k�2Y�I�j�?�]Ѷ�� �3�7�'qr����.y��Z�1��IR,�2k~�6u8���0T�yث"��#B]V�პ��t �V[e$������QDzli�H�!�0D%��0W�����e�<E]�n�:�{��N>�VV�;��9lV���FTb'���j=�Z[�Q+��!�:���V�BZ�Y,�o�.b�k<LUQ�����21|2��2Bso��x�� �N6���ޘy�ߠ)~ց ��H����GE�5n���C�-I߬����������轩H�P"����Ĩj&�ӅB{��d���~C��Y>	���>��A�p�?�Nƭ,�gD,�����pix�0�O@�H2pe�?4V�2V�<�Ӄ�
P���˸D�����������
P�'�1��d��a��N����$�J-��ChH�ԟo.�4tS�67#WV���U���K���UJ�p��h���*�-2��XٲY��_����[h�7W�����AYw�6|�ƌdи�F-I?�w3pe��K����w�pT�bG�&��1��f��
o�[�B~��r�F�Q~ C���\Y�.Ę\\��S�����8:t�F2V�Q�oA��vB�S���N�����D7�f��L+7�qLh�(�A%��ן_	�I�j�?JB�`j*������ +a��i�5���|���\�+���-v�I_�>�7]�����_hǏ�1�^���q~ �Z�õF���_�:�C�0�H��� :t���˓37CW4�X�Y҇�<�lӮ�Lg"�����)�]���{tWQ�n��18��݌�arml7W:��1��z�p7Q,�9��a�����f�j@�+����w�Z.8�Gc�;�
�#cmT��B��G�ɤ�ԛ���E��O�0��Y�~2����m��$���&-1�w3t5���F�˸�no�"�nz�<��u�~7cWB�1oH�(
�Pρ�BJ���PS��,�����ٽ�S(�L.gHa}�Lml�Hܐ�}�����^���N{�s|��m�[��7�E��;����^4,a[�T���7I��!�n��>.�X&��Ä ��ss�'+� ���^(}��<|(b̃5����C^��M����Հ�g]Q?	��EUt�o��=}��Z��f�j@�c�P�ഊ�P͏W�����������R�ǃCa�S���R�������Հ�W�#�~tJ������-`b��`�2|5��y~Y�$0b!�����-�[����]�`�0��H�Q���=�%�:��bt����4���J�dKQD?|��^}���1!�����R�Z��X�Yk<L�ٽ_o/`bc�'��熀��`D��4cWÓ{o��Ͽ��#�&�m4��e��������4�Z���ZT{!�H�6��{3x5��5Hk�l~�"]��|@��%D��o��t��m�����,�zc���] $f�˃d�j����Gc���(���B_RYnK�K-^%Y�$ h��ќ}nny� ��y��d��TZ##W���9 �uPZ	�s��E����2:��� ������e�CC�a��?�1��d��� D0;6�ɞ��jF��V���o��������^��V��)��<��"�j�d2r5=��_�:8��Ѷ!WtG�U�I�:=���9�qTТ����Q��4�|ʑe�j t�Д�!��]�LEFu�(�k7W� �Sލ&/ԯ���a(2�o���z�o��Fgo�s��E+o�(q3d�B�,^�a�����e�9݇��M鸱1OFwT+^&CW��߃`]K��a�8)A��Λ��5�������O�_蕀�ªl.��	;�W"���NMƮ&���݌ �+�b�B���x2��]M�FA���PVb)8L�a*�* ��E֪��/�����R���?�����:asƮ&�?<�h�=��tEl��X[��3��nƮ&׿�Y�п����O�n� om�����a����BD&ѩO��!���*&z��Rܤ�� ���>Zc�6��ub�u5�62���\0}4�bZ�.=�`���<H0�փd�j(���C��}B>��rk,<R�m��d�jPJ#����D��k#$����\��ۂ<���A��Q�!;̃<�U! �����(����'t�`����Q��0UE �s�I`�Ц�w4�&_��df��� wC��2O,a
Z��+�z7�Q���f�j/Eo03)a03L���
��y��M2�E0��~0{��j��:��u�E2r����l9�xZ:V�!{�9N��ɰ�rO_�A;��X�;bE1m�	�m���Ͱ�"@�x��M�]_��c���1���v4�V� �A�8�~t0(o�PX�Tʀ�_u�3j�� �b�W���!6-2���G���s$+] ���3�r
ޙB�qԊ������5��. ���:�X�I]�"��.�|&	���N�Ub�t�I-���ᵆ��Z- 
1g�SQ�4_���B�$�s�1��m� ��ݴ��Yk��h��A�zƬ���3,$I�H��ɤ��F��m��d�yت��!��J�f+oǌL����@~F�1�E �,�����ͤ>h�G�4p�    �@V�A�E � �ފz�`DX�`� Fp�Gy���*`~FG��:�1��\ N�Ed�j ��h��qΒ�g¥�����DD�Z\��o�sîT�"/^[ .8v�r�<��R;��=�a@�����+�]T���P�i�f����ɋ�`���}�����PQ/�b���2��HL�s[����Ș��e�b��x7#V��[nmt� �Qѿ5���b�6����E�ʼ^h�xQ��ϊ-��b=GE���}�Q+����jV��F8(����ޔ���3le���޷H��Bs���O2�d~f�2x�w3pe�?f����?���Wbx8UVʕ������u��G��f/p�(��/T�f�^���x��B��)
��{��ܾ�x����ř�[Y�Ɵ��XL��U
�,6�����H�j�?�����:&����䄌����1+K���C.1���`F�3ڼ���5WMƬ,�IQ��;��&V���:}�`5�2fe�����y�5�7.��ݽ������H��*Շ��^��L~ĪD g�lV`���j�E*��3kh�/�t.��s��힌����E��Z�M/_�����9��U���d~��J2W��ѥ�B���3�f|-F�,��V_Г�%CW��
�\�
ݩd?O�5CIa�(.e�d����j��}1v�"��&�������*�m� �S#���u)���O��()$�[̫tD�vt�1�Hh0����A�?J������p����)�)��nɏǣ�bҀ��*�m�F\��(��� ƈK*�ډ��/:��\�Ҙ����XZk��&W��DW���o�A,+�y����10�����s�:}�BĲ���0�H�ao��)5��B閖�	i�U�ۙ�ګ� m�Ǜ� �Г������?�dˊ���ܪ�3��ІA�)�F���a�������đS� �Pi�,Րas���pG�q��%WřE�&�������m�_L.CY|��t��k ��� Y5�ߟ�a�c�#{�W(��eb�[�0,G7��"�����S��a�~$5��%}4��sh�"�p�Ƹw�p��/��h���I�v%/NP�6A���ЯRDG|3f��2�6��oy�팙�1�0]�4�����E��9�,�ڹ�� �dNޚּ��ap$�0�=�{�*���RXi&v�g��1�7
{V��Ɔ�Z������ͩc�-��o��A�jP�c�d������(^Q� nt���� mr�3�u@���Eqy�e�K��U�mG�V[�"�j��
�ߧY��ˊԶ�R˽�.�H��J2�㯶c�(��eO���v;��f"��*�:p��4�hKEK��ǃ��	+�Iak�<���J��P}�K��AXBQ�������Kƶ�?����4�t�7����z��š�֒������GC��#k9��LJwvO���g|�@����E�JEs8�Ce�����<,��~"%"g�M��2s�(�^�a��>�o�]��S�H"	p-��4�w~�?��"#��@�ј#����6�T�@��G"�Xd�h�/�mT�S�(�� SV�/J�v��:��(A��ds�h���A�5(��`��Uz���o�2 @�V����R*Ȯ�6c] -�; $���V�ҿ�T�t�.<7�]��X���h�x�[t����� ���:� ���-��U��&;F,�t+f2r3�u����P���;bj/s���j��r�:� �Lf�B�b~�����A=�Ef;��뇡⃐��^�2+�|G��<Vy��`�j�UJ[Aj��c�G��o�q��/��0��կ}o�h���%T2���>6���*P��8�A��7R�c�ẛZkd��'���;p�֠D7@����o��MƼa�G��;F�KN���RI�YXnVy�����wu?#U���u_�"��0�}2�u ��G���$`j"43`M;��Z
�07�>&�YL���`Y��� TXu�2�u�����^hk@�9��@���$���	��㠨�:yAx�.�1B� 1�"�h/Q��e�p�0%J��W���ar�a����	��#�����P=٦@Gh��;�l�%P�"��>9MְD��T���bh�����U%�5�n(W3�O�č���i��ѯK� [׻�C�	h��CtMS��6�0��~]�����B�f��|����Z@��U��^�D�>.��T�w�t*�������3v	"��cG�5�����6����f�#P��)HA0��0=�g�F�Cy�Ü1�K�@�,�d;P-�A�&�J�(�w�a��ٟ+zz�1�4�DM��ه������K�`�Q;V�<��
xaԐ(�:��X�%F���|�EB��i]=�������̋t����ա�43��Q%l9GF�56� |��a�.�q�:��,�h�wa����3�C�6�G���F�L*�^�8r^e��ނX/��]-�R�Gh���ރ�2���*'Y�W�%:��^p+�� @^���jm؟�7Q@�����IM��;��8?�D�E�#��e6����3�ID�X�a���tR��fL��7� ���M�a�
�r�M]�VJz�����&F����j ,�/�������� �����3*v����1���tg�6���\d^ma��Ͱ�%F�g�ၥ�7�;7us��`綃˰�%DXs��8���0w����{d����Vy���ǵ~�8����kiB���޲��j']��GpP��A�W��u�6��#�9�c�"��A[��Ѝ�+z��M��=�bn���
����b�9A��<�h?r�����Y��nYe0���"ɍv��Al�P����PMǤ	 c����'���E��X�9��P��GB�X� IG����4�MI8|'\
�l�lW�B�E$�W�T��
I"ŀ1�A��XB������
ݮ���ޘ����8�P�)�����m�,A�k�б!"B�'�2�$�'����6!d���+�Ia�mY���Ɍae�dt��*�m��r�Ԉ��F��������.�ʉ|,ad�r�\'�����*;6~�5��7W�w�a�
�Z�F�%t[o��̴��UV��x%:���H��B�w�m 2���ym���݆��,O��y]ha��4�UFK!�q5s/�P���M�D3��������I������ y���N�$�R(���U�
�8����~�{�
J���EvK3�"�q�ĵ�s�`7*�B�����"���p|�L���� F�3R���.F���h�%dؤ��ȖN�{H��ƜLz�6�U�@KZ4���7b�o��a��{�hPM(Y���t	i*ٜ9,?����"!C<�>�ti� ���rC���D��|n�9��������0����CE�< �E=�̐�
�<��nB��QX�be	Z��E!���@/D��GI Y-�O���G]r9c���%b�l�b����Q�{�hd��@�6��˝,�0Z:
�Wb㡕 =|u|�����F�<������^F����T�(��܋�v�s���li*<��4����@\��;� ��1��'9�d��ȁ����5���C�	����Ԅ��H���,�(�M��4��s+Ҡ��;k$���#�HA0	�5.�{��{�J^VIF[�V��A�+4D�)C����jO�t��>�P��V�R�t�K'��-����&�Z�R��QɫT��l'(�Q�]֮0fV=Fun��p|B��X�����Q�kHz���R��f��	"cw~���N����J+U�-��ӏ�l�Fo�7j���џe$�ÝJ�I��,�I2���%Fٹ>�B�!á(N���b�Hj��$6Gӊ���*K���#Qe���26��!�V�5Eh����K��E��<����hOD��B7������Q��~���6�\������FMt?����j���* �  �et (n� �q�PwT���R�r�H���V�F3)�(.E��̏r�{�*j��X�I����+��2ͬ(J��9�_4o�m��Xe��MB;�i�;�8s��;��g�]^d��g�P���rxAE�i����*�����sTٌ;�G֐��	��C.w�5%tL��b�xc#q�P7˧l�C",CU���^8�"bI���}*�*�H���r����|��0[�}�,��hs>P�c&��{Ͳ�Da���2D��r��3�X<8�VDn /��M��*�e� a[��@}b8)":~N|,z� !�c��{,��� .�۠M:d���0���H�����=G�	8T����YZTH蚰�&l�E�]�h!Qh��n��榣��y�_:PW�B����b04��)r>s�<C�/�� m���-��"Cqz^�����1��C.�Վ���o�'c�5rm������U�a30Ս�~�^��Њ�����&�m�;����B3ͥ	Q�4A�͌aF��&�m�<��c%&>�0������'��U�_K��Nh,�R:%n�caz#�eA��*5`��	�.�ƃ�o�7S7#0XHq �$�mn?�ED�O����3'�����M�^%�n����^غ�|��[�^
8�(j2��RiM�e��)Es�tn��J����U��´s>tB���J�\|�ܟ��Hs������-$Lb҅	 �X?�	zX��Io��B��X�#�p�C�SqOe ��8$�XK��Xd���< �f���5Ț3�<*^(k��Xe{ w��cUT���1_���C�b���6O�������p~]��(�2)I�%�L����QΡS��U���������%��U:ܤE�t<<��#�{�#������Ȅ��cF>y$�'{O���p�;LH�kx�h�.L�"�7�4���98�~Vy-��X�+�̀Z#�q�3x�:�@��E6;<�4�ڊ�}���M�]kS&�	c��:r4�O��tr��Wa���f�?��h&tO��C@��Q2wJ���:�� 慱��f�E,�kq�ܘ��k�wdi�L1���"���Ɉ���"�o 8��C%yfg�3����cƿf/H��UKFs{8�Q^�a��#��8�"�5d�� ��5�����C�2V�;���b�'��$��G��`�U�3'��U��w|��>HL�j�s�|�mWh/���jݔ�#
�xct�<���p�r ��`�d�=�w���4�i�4��"���l!8�P���D��Cʲ�0�`�Θ�ńJH�j�3Մ�����9�Q�5s�,��ԍD8*tq�2Y%�mw{�_�O��d�Ac udbr�	$�M�c�d�����ϡ6n��ia��<�_qBm.vq	#�*բ`;��'j�ר���a����%��UhQ���B��vڧ��9t�a׿F�"���oZ1�ς�?���b�� Ci$��E6m}A�tD��XR'f�Z��:ͨj$��E��	t��zosO��߁,#�����mj�B��ת�����@�=���f�j3@�ݥxO��R1=n|���� ��i��rQ�Ǻ���~>��]�$��c\�"wz\]���Xw�b��.fPY
q��b��]��e���ҧh��?�+���[jh!Ö-E" w����6EX�=�RN����C�aElm7'9�c�}�+H�Ǘ8Ij�A��RP�q5/�cݍ��1�Z�s~R��)F���v�Ǻ{�33�a�c�_�j!�e�#�6��X�a�L$��EAW^c~��Q=���f��(�c�튞���0�x�V�����R�b������h"��BnL��&g�����4AM�m�csV���D��
Ηqn^�P�Aaw  �֕��ub�%��3oD��.,\�T�t����{ֈ����5���'�aҠ���2<�	6��1֊��z�M_⏠����,�0[:o��Ȑ�ouS�n��۴�3�f�*�e�޼��U�B�k~,��x��@����u"D-tT�fp�b�m.m��G��UvK�"L��2�f�5�#�iM��;<��U���"�Pi�ʥ�����"�f:�d�d���A�8�<l�����cU��If;��������Pm����C�L��ZIVk	CJ�����zF�7������E��Z��X��2��%//a�_f�"������5雎�k�eB����;5�j����dx�"��]<owR����9`�y��@��2<fCY�pи�B���k�FSPy�gh����������)F�&B*���ݼJ�Y���x�|Qe�d�!PGfCFݤ{���6 d�g�T����Ҽ6�N���*�m���c�֔��p���t�QS���Ѭ_�.%3�ī��Z��oV�~���Ҷx�����]�����	[Bga{[VK�":.���������a���nu��c�D^��0��3v����G����x=��m���Q����x�H���A�Ŧ�[[�Ȇ������}!�Gk����|�L�m�A���o>���X��|�<?V$�ጰ�%P	
�r穤�(�,���K`�C���~���ҸH�d�<+MmqE�j�f�)}3N6ܸHt3,���,�㟹��/�@?��ӥq�/�.B7��(.����2���Y�K������R@A@ Q�B�\Y��>�E�K�<�I���e�%��h�䲇D��N*�-e��
-��G�4���|�XUS,����2N6<����ȶ.�w����F��PNF�2N6<�����0E��ĘW�$��t�p�e�l@&����b�)���W(|�B����F��a�	����_�4�qt5�]dȒ sV�/���m+
�=]w}�(�4Y�I�W��������ޮ�*	��9V����r�A����c��Xe�V��ɋF�G��w P�E1�.��?����g�h��2*�P�H����
�	�x��'P���<�~���mM�H:	��
p��7��@Y���������}^��4$/�rָ��˯�'R��r�x�:(��d�([��<]�\T�7S�?�2��������:e���=���8~��_�TϕF���*v%�m[$�f�k@S��"e�*hQE�?��-x��UJ�:?�cǣ��"ׅȘVZ �s{�������������bJ=J�݌�$�C�/����J�!�O��[�[�$j����%��Q̦hY��I�V���EƆ#�E+�����_H�#�j����Ejq#����
�2�q� �0ϵ�@�*󿍖U��?>N�I#Ek}qg���Ӈ����$k�X�ksV!*��VK�[�� �7�j�O���#Y?��"?e؀���BĠ�U|X��E����(H"GE8[��y�d��8��O���cYx,Xd�2�ó\�`o�\X��?���d�F	ş� ��ڙ����8uXVY�U�����1��0e�L�
Jk����~,B����kb�0�*b_�j�$ �`�r�*���ǠyP#�14�����m��ޖ��o��m  A(�3�1�#���s��������ק
��)�{e"#3�Z3�e	��\5��$�K��V��x�$gb/ߤՀP���uI��T��'ծ��"�	�|� �AN�]�� ��|     