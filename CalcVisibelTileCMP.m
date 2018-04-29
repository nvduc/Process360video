clear;
% Viewport
FoV_H = 90; % horizontal Field of View
FoV_V = 90; % Vertical Field of View
Fh = pi/2;
Fv = pi/2;
ERP_W = 4032;
ERP_H = 2016;
FACE_W = 1152;
FACE_H = 1152;
vp_W = 960;
vp_H = 960;
No_tile_W_arr = [2];
No_tile_H_arr = [1];
No_scheme = length(No_tile_H_arr);
phi =0; % Longitude  of viewport
theta = 0; %altitude of viewport
No_face = 6;
%
for scheme=1:No_scheme
%for scheme=1:1
    tic;
    No_tile_W = No_tile_W_arr(scheme);
    No_tile_H = No_tile_H_arr(scheme);
    tile_W = FACE_W / No_tile_W;
    tile_H = FACE_H / No_tile_H;
    No_tile(scheme) = No_tile_W * No_tile_H; % numbr of tiles per face
    fileName = sprintf('visible_mask_%dx%d_FoV_%dx%d_%d_%dx%d.txt', ERP_W, ERP_H, FoV_H, FoV_V, No_face, No_tile_W, No_tile_H);
    disp(fileName);
%     fileID(scheme) = fopen(fileName,'w');
    % calculate boundaries of each tile
    % tile_id starts from 1 to No_tile
    for j=0:No_tile_H-1
        for i=0:No_tile_W-1
            tile_id = j * No_tile_W + i + 1;
            LB_tile_W(scheme,tile_id) = i * tile_W;
            HB_tile_W(scheme,tile_id) = (i+1) * tile_W;
            LB_tile_H(scheme,tile_id) = j * tile_H;
            HB_tile_H(scheme,tile_id) = (j+1) * tile_H;
        end
    end
end
    %
     for m=0:(vp_W-1) % width position of point on viewports
         for n=0:(vp_H-1) % height position of point on viewports
             %
             u = (m+0.5) * 2 * tan(Fh/2)/vp_W;
             v = (n+0.5) * 2 * tan(Fv/2)/vp_H;
             %
             x = u - tan(Fh/2);
             y = -v + tan(Fv/2);
             z = 1;
             %
             x_(n*vp_W + m+1) = x/sqrt(x*x + y*y + z*z);
             y_(n*vp_W + m+1) = y/sqrt(x*x + y*y + z*z);
             z_(n*vp_W + m+1) = z/sqrt(x*x + y*y + z*z);
             %
         end
     end
    % calculate the visible mask corresponding to each viewport
%     vp_id = 1;
    No_vp = 181 * 360;
    A = zeros(3,vp_W * vp_H);
%     for phi_deg=-180:180
%         for theta_deg=-90:90
    for phi_deg=[0:359]
        for theta_deg=[90 -90]
           tic;
           phi = phi_deg * pi / 180.0;
           theta = theta_deg * pi / 180.0;
           % rotation matrix
           R = [cos(phi + pi/2)   -sin(phi + pi/2)*sin(theta)     sin(phi+pi/2) * cos(theta);
                         0                 cos(theta)                      sin(theta)                ;
                         -sin(phi + pi/2)  -cos(phi + pi/2) * sin(theta)   cos(phi + pi/2) * cos(theta)];
           
           % obtain all XYZ points of the viewport
           A = R*[x_;y_;z_];
           X=A(1, :);
           Y=A(2, :);
           Z=A(3, :);
           f = zeros(1,vp_W * vp_H);
           u_= zeros(1,vp_W * vp_H);
           v_= zeros(1,vp_W * vp_H);
           % calculate (f,u,v) corresponding to each (X,Y,Z)
           % face 0
           a = abs(X)>= abs(Y);
           b = abs(X)>= abs(Z);
           c = X>0;
           d = a & b &c;
           f = f + 0 * d;
           u_ = u_ + d .* (-Z./abs(X));
           v_ = v_ + d .* (-Y./abs(X));
           % face 1
           a = (abs(X)>= abs(Y));
           b = (abs(X)>= abs(Z));
           c = ((X)<0);
           d = a & b &c;
           f = f + 1 * d;
           u_ = u_ + d .* (Z./abs(X));
           v_ = v_ + d .* (-Y./abs(X));
           % face 2
           a=(abs(Y)>= abs(X));
           b=(abs(Y)>= abs(Z));
           c=((Y)>0);
           d=a&b&c;
           f = f + 2 * d;
           u_ = u_ + d .* (X./abs(Y));
           v_ = v_ + d .* (Z./abs(Y));
           % face 3
           a=(abs(Y)>= abs(X));
           b=(abs(Y)>= abs(Z));
           c=((Y)<0)    ;
           d=a&b&c;
           f = f + 3 * d;
           u_ = u_ + d .* (X./abs(Y));
           v_ = v_ + d .* (-Z./abs(Y));
           % face 4
           a=(abs(Z)>= abs(X));
           b=(abs(Z)>= abs(Y));
           c=((Z)>0);
           d=a&b&c;
           f = f + 4 * d;
           u_ = u_ + d .* (X./abs(Z));
           v_ = v_ + d .* (-Y./abs(Z));
           % face 5
           a=(abs(Z)>= abs(X));
           b=(abs(Z)>= abs(Y));
           c=((Z)<0);
           d=a&b&c;
           f = f + 5 * d;
           u_ = u_ + d .* (-X./abs(Z));
           v_ = v_ + d .* (-Y./abs(Z));
           %
           m_ =  int32((u_+1) * FACE_W/2 - 0.5);
           n_ =  int32((v_+1) * FACE_H/2 - 0.5);
           % calculate visible mask
           for scheme=1:No_scheme
               pixel = zeros(No_face,No_tile(scheme));
               for tile_id = 1:No_tile(scheme)
                   a = m_ >= LB_tile_W(scheme, tile_id);
                   b = m_ < HB_tile_W(scheme, tile_id);
                   c = n_ >= LB_tile_H(scheme, tile_id);
                   d = n_ < HB_tile_H(scheme, tile_id);
                   for face_id = 1:No_face
                       e = (f == (face_id-1));
                       pixel(face_id, tile_id) = sum(a & b & c & d & e);
                   end
               end
               vmask = pixel > 0;
               disp(pixel);
%                fprintf(fileID(scheme), '%d\t%d\t', phi_deg, theta_deg);
%                fprintf(fileID(scheme), '%d\t', pixel);
%                fprintf(fileID(scheme), '\n');
           end
%            disp(reshape(pixel, No_tile_W, No_tile_H)');
% %            vp_id = vp_id + 1;
%            % record result
%            fprintf(fileID,'%d\t',pixel);
% %            fprintf(fileID,'\n');
%              timeElapsed = toc;
%              disp(timeElapsed);
%              return;
        end
    end
%     fclose(fileID);
%     timeElapsed = toc;
%     disp(timeElapsed);