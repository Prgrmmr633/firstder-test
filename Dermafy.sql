PGDMP              	        |            Dermafy    16.2    16.2     �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16398    Dermafy    DATABASE     �   CREATE DATABASE "Dermafy" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
    DROP DATABASE "Dermafy";
                postgres    false            �            1255    16448    update_date_added()    FUNCTION     �   CREATE FUNCTION public.update_date_added() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE user_inputs
    SET date_added = CURRENT_TIMESTAMP
    WHERE id = NEW.id;
    RETURN NEW;
END;
$$;
 *   DROP FUNCTION public.update_date_added();
       public          postgres    false            �            1259    16400    predictions    TABLE     �   CREATE TABLE public.predictions (
    id integer NOT NULL,
    confidence_score double precision,
    read_more_url character varying,
    name character varying(255),
    date_added timestamp without time zone
);
    DROP TABLE public.predictions;
       public         heap    postgres    false            �            1259    16399    predictions_id_seq    SEQUENCE     �   CREATE SEQUENCE public.predictions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.predictions_id_seq;
       public          postgres    false    216            �           0    0    predictions_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.predictions_id_seq OWNED BY public.predictions.id;
          public          postgres    false    215            �            1259    16409    user_inputs    TABLE     �   CREATE TABLE public.user_inputs (
    id integer NOT NULL,
    image character varying,
    prediction_id integer NOT NULL,
    date_added timestamp without time zone
);
    DROP TABLE public.user_inputs;
       public         heap    postgres    false            �            1259    16408    user_inputs_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_inputs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.user_inputs_id_seq;
       public          postgres    false    218            �           0    0    user_inputs_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.user_inputs_id_seq OWNED BY public.user_inputs.id;
          public          postgres    false    217            �            1259    16457    user_inputs_prediction_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_inputs_prediction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;
 4   DROP SEQUENCE public.user_inputs_prediction_id_seq;
       public          postgres    false    218            �           0    0    user_inputs_prediction_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.user_inputs_prediction_id_seq OWNED BY public.user_inputs.prediction_id;
          public          postgres    false    219            W           2604    16403    predictions id    DEFAULT     p   ALTER TABLE ONLY public.predictions ALTER COLUMN id SET DEFAULT nextval('public.predictions_id_seq'::regclass);
 =   ALTER TABLE public.predictions ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    215    216    216            X           2604    16454    user_inputs id    DEFAULT     p   ALTER TABLE ONLY public.user_inputs ALTER COLUMN id SET DEFAULT nextval('public.user_inputs_id_seq'::regclass);
 =   ALTER TABLE public.user_inputs ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    218    217    218            Y           2604    16459    user_inputs prediction_id    DEFAULT     �   ALTER TABLE ONLY public.user_inputs ALTER COLUMN prediction_id SET DEFAULT nextval('public.user_inputs_prediction_id_seq'::regclass);
 H   ALTER TABLE public.user_inputs ALTER COLUMN prediction_id DROP DEFAULT;
       public          postgres    false    219    218            �          0    16400    predictions 
   TABLE DATA           \   COPY public.predictions (id, confidence_score, read_more_url, name, date_added) FROM stdin;
    public          postgres    false    216          �          0    16409    user_inputs 
   TABLE DATA           K   COPY public.user_inputs (id, image, prediction_id, date_added) FROM stdin;
    public          postgres    false    218   �       �           0    0    predictions_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.predictions_id_seq', 20, true);
          public          postgres    false    215            �           0    0    user_inputs_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.user_inputs_id_seq', 20, true);
          public          postgres    false    217                        0    0    user_inputs_prediction_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.user_inputs_prediction_id_seq', 1, false);
          public          postgres    false    219            [           2606    16407    predictions predictions_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.predictions
    ADD CONSTRAINT predictions_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.predictions DROP CONSTRAINT predictions_pkey;
       public            postgres    false    216            ]           2606    16416    user_inputs user_inputs_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.user_inputs
    ADD CONSTRAINT user_inputs_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.user_inputs DROP CONSTRAINT user_inputs_pkey;
       public            postgres    false    218            `           2620    16449 *   user_inputs user_inputs_date_added_trigger    TRIGGER     �   CREATE TRIGGER user_inputs_date_added_trigger AFTER INSERT ON public.user_inputs FOR EACH ROW EXECUTE FUNCTION public.update_date_added();
 C   DROP TRIGGER user_inputs_date_added_trigger ON public.user_inputs;
       public          postgres    false    218    220            ^           2606    16443    user_inputs fk_prediction_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_inputs
    ADD CONSTRAINT fk_prediction_id FOREIGN KEY (prediction_id) REFERENCES public.predictions(id);
 F   ALTER TABLE ONLY public.user_inputs DROP CONSTRAINT fk_prediction_id;
       public          postgres    false    216    218    4699            _           2606    16417 *   user_inputs user_inputs_prediction_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_inputs
    ADD CONSTRAINT user_inputs_prediction_id_fkey FOREIGN KEY (prediction_id) REFERENCES public.predictions(id);
 T   ALTER TABLE ONLY public.user_inputs DROP CONSTRAINT user_inputs_prediction_id_fkey;
       public          postgres    false    216    218    4699            �   �  x���=o�0�g�WhtIw���$�,:u!d�%J��D�H}O��~P O$��=���b��ʂE��Q��9�m�^.��ŏS����tih]��|
7����������R�:e߹�5�l�v+�V�F
F�Ȉ
Qp��
�,��0��b�8>�0�km�֊s��=��4��I_���]��O��kRK�F"ZZ>�O��)�S�)�𕂛i&�0a92ŌV�՚ڟ}H~�s��Ċ �GN��f��B�?�Y�bd��$������@���%j"���pP�	�R�R��.�C}v����D��y�6�=�jG�3������Brc�����_��)����E��j�e�n:(.-(	�h#����<����y9}�b0����\P�~4�+J] ]���h\[��b7�û����)��7��H�      �   v   x�}�;1�:>ج��$v�B�BB��_AAaQ�i�����K���(¢��� _]�z�0!H���kK�ƪi������?^�_��[5�%�XgZ-VK���Y���+} ��^/     